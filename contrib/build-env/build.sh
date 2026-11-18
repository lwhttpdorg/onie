#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 4 ]]; then
    echo "Usage: $0 {download|build|clean|distclean} [machine] [vendor] [jobs]" >&2
    exit 2
fi
action="$1"
case "${action}" in
download | build | clean | distclean) ;;
*)
    echo "Unknown action: ${action}" >&2
    exit 2
    ;;
esac

workspace="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
project_id="$(printf '%s\n' "${workspace}" | sha256sum | cut -c1-12)"
name="${BUILDER_NAME:-onie-builder}"
image="${name}:2026.08"
docker="${DOCKER:-docker}"
machine="${2:-bkhd_g30w}"
vendor="${3-bkhd}"
jobs="${4:-$(nproc)}"

if [[ ! "${name}" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
    echo "Invalid BUILDER_NAME: ${name}" >&2
    exit 2
fi

if [[ ! "${machine}" =~ ^[[:alnum:]_-]+$ || ! "${jobs}" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid machine or job count" >&2
    exit 2
fi

if [[ "${vendor}" == /* ]]; then
    vendor="$(realpath -m -- "${vendor}")"
    case "${vendor}" in
    "${workspace}/"*) vendor="${vendor#"${workspace}/"}" ;;
    *)
        echo "Machine root must be inside ${workspace}: ${vendor}" >&2
        exit 2
        ;;
    esac
    [[ "${vendor}" == machine/* ]] || {
        echo "Machine root must be under machine/" >&2
        exit 2
    }
    vendor="${vendor#machine/}"
fi
if [[ -n "${vendor}" && ! "${vendor}" =~ ^[[:alnum:]_-]+$ ]]; then
    echo "Invalid ONIE vendor name: ${vendor}" >&2
    exit 2
fi

# ONIE defaults to V=0 (quiet).  Pass V on the make command line so it
# propagates through MAKEFLAGS to all recursive package builds (grub,
# kernel, busybox, ...); otherwise those sub-makes default to verbose.
make_args=("MACHINE=${machine}" "V=${V:-0}")
if [[ -n "${vendor}" ]]; then
    make_args+=("MACHINEROOT=/build/onie/machine/${vendor}")
fi
if [[ -n "${ONIE_MIRROR:-}" ]]; then
    make_args+=("ONIE_MIRROR=${ONIE_MIRROR}")
fi

command -v "${docker}" >/dev/null 2>&1 || {
    echo 'Docker is required' >&2
    exit 1
}

container_exists() { "${docker}" container inspect "${name}" >/dev/null 2>&1; }
if container_exists; then
    scope="$("${docker}" inspect --format '{{index .Config.Labels "org.onie.project"}} {{index .Config.Labels "org.onie.owner"}} {{index .Config.Labels "org.onie.role"}}' "${name}")"
    [[ "${scope}" == "${project_id} $(id -u) builder" ]] || {
        echo "Container ${name} belongs to another project or user. Set BUILDER_NAME to a different name." >&2
        exit 1
    }
fi

if [[ "${action}" == distclean ]]; then
    if container_exists; then
        "${docker}" rm -f "${name}" >/dev/null
    fi
    if "${docker}" image inspect "${image}" >/dev/null 2>&1; then
        "${docker}" image rm "${image}"
    fi
    rm -rf -- "${workspace}/targets"
    exit 0
fi

if ! container_exists; then
    [[ "${action}" != clean ]] || exit 0
    image_key="$("${docker}" image inspect --format '{{json .RootFS.Layers}} {{json .Config}}' "${image}" | sha256sum | cut -d' ' -f1)"
    "${docker}" create --name "${name}" \
        --volume "${workspace}:/src:ro" \
        --label "org.onie.project=${project_id}" \
        --label "org.onie.owner=$(id -u)" \
        --label org.onie.role=builder \
        --label "org.onie.image=${image_key}" \
        "${image}" >/dev/null
elif [[ "${action}" == download || "${action}" == build ]]; then
    image_key="$("${docker}" image inspect --format '{{json .RootFS.Layers}} {{json .Config}}' "${image}" | sha256sum | cut -d' ' -f1)"
    container_key="$("${docker}" inspect --format '{{index .Config.Labels "org.onie.image"}}' "${name}")"
    if [[ "${container_key}" != "${image_key}" ]]; then
        "${docker}" rm -f "${name}" >/dev/null
        "${docker}" create --name "${name}" \
            --volume "${workspace}:/src:ro" \
            --label "org.onie.project=${project_id}" \
            --label "org.onie.owner=$(id -u)" \
            --label org.onie.role=builder \
            --label "org.onie.image=${image_key}" \
            "${image}" >/dev/null
    fi
fi

stop_builder() {
    local status=$?
    trap - EXIT
    "${docker}" stop "${name}" >/dev/null || { ((status != 0)) || status=1; }
    exit "${status}"
}
trap stop_builder EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ "$("${docker}" inspect --format '{{.State.Running}}' "${name}")" != true ]]; then
    "${docker}" start "${name}" >/dev/null
fi

if [[ "${action}" != clean ]]; then
    # Copy Git metadata too: ONIE derives its release tag from the checkout.
    # Keep downloads, toolchains, generated sources, and images in the container.
    "${docker}" exec "${name}" rsync -a --no-owner --no-group --delete \
        --exclude='/build/' --exclude='/targets/' \
        /src/ /build/onie/
fi

if [[ "${action}" == download ]]; then
    "${docker}" exec "${name}" make -C /build/onie/build-config "${make_args[@]}" -j"${jobs}" download
elif [[ "${action}" == clean ]]; then
    "${docker}" exec "${name}" make -C /build/onie/build-config "${make_args[@]}" clean
else
    "${docker}" exec "${name}" make -C /build/onie/build-config "${make_args[@]}" PYTHON=python3 -j"${jobs}" all
    prefix="$("${docker}" exec "${name}" make -s -C /build/onie/build-config "${make_args[@]}" machine-prefix)"
    "${docker}" exec "${name}" bash -c '
        shopt -s nullglob
        images=(/build/onie/build/images/*"$1"*)
        ((${#images[@]})) || { echo "No ONIE images found for $1" >&2; exit 1; }
        mkdir -p "/build/onie/targets/$2"
        rm -f -- "/build/onie/targets/$2"/*
        cp -a -- "${images[@]}" "/build/onie/targets/$2/"
    ' _ "${prefix}" "${machine}"
    target="${workspace}/targets/${machine}"
    mkdir -p -- "${target}"
    rm -f -- "${target}"/*
    "${docker}" cp "${name}:/build/onie/targets/${machine}/." "${target}/"
fi
