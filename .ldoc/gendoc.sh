#!/usr/bin/env bash

# Place this file in mod's ".ldoc" directory

d_ldoc="$(dirname $(readlink -f $0))"
d_root="$(dirname ${d_ldoc})"
f_config="${d_ldoc}/config.ld"
d_export="${d_export:-${d_root}/docs/reference}"

cd "${d_root}"

# clean old files
rm -rf "${d_export}"

vinfo="v$(grep "^version = " "${d_root}/mod.conf" | head -1 | sed -e 's/^version = //')"
d_data="${d_export}/${vinfo}/data"

parse_readme="${d_ldoc}/parse_readme.py"
if test -f "${parse_readme}"; then
	if test ! -x "${parse_readme}"; then
		chmod +x "${parse_readme}"
	fi

	"${parse_readme}"
fi

# create new files
ldoc --UNSAFE_NO_SANDBOX --multimodule -c "${f_config}" -d "${d_export}/${vinfo}" "${d_root}"

# show version info
echo -e "\nfinding ${vinfo}..."
for html in $(find "${d_export}/${vinfo}" -type f -name "*.html"); do
	sed -i -e "s|^<h1>Sounds</h1>$|<h1>Sounds <span style=\"font-size:12pt;\">(${vinfo})</span></h1>|" "${html}"
done

# cleanup
rm -f "${d_ldoc}/README.md"

# copy textures to data directory
printf "\ncopying textures ..."
mkdir -p "${d_data}"
texture_count=0
for png in $(find "${d_root}/textures" -maxdepth 1 -type f -name "*.png"); do
	if test -f "${d_data}/$(basename ${png})"; then
		echo "WARNING: not overwriting existing file: ${png}"
	else
		cp "${png}" "${d_data}"
		texture_count=$((texture_count + 1))
		printf "\rcopied ${texture_count} textures"
	fi
done

echo -e "\n\nDone!"
