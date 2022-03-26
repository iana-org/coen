#!/bin/bash
#Replacing auto-generated UUIDs with canned ones

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

UUIDS=("0f0c26df-7d17-477a-8ab7-dc18171d51d3" \
"b2b612ab-5860-4dbd-9cd0-79975ece9d16" \
"c4ab05a9-c97f-40fc-98cf-e7beb54417d5" \
"0fbca36d-bb9b-4549-92cd-7bd273d1a288" \
"2fbeb213-248b-4295-9e94-0d64fb3fb54f" \
"3e3df186-c868-4edd-9df4-34a7f5dc6965" \
"1d14b810-f4d8-4467-8ca0-3e3df96b874d" \
"5ed6b7a5-c12c-49ce-9c59-8a2f99082047" \
"1299ff86-943a-491c-99f0-d6a0429a4972" \
"1f4c3c98-253d-4164-a7aa-b3d43eabeb8f" \
"17ce9547-e284-49ea-ae96-2d820e4445d4" \
"b27ce806-3f4f-41a9-8a13-19f1b0208869" \
"eedcbd9b-62c6-40a2-a4fe-d8c63b36f0f6" \
"ec7047eb-5ec4-4539-b8ca-476e96f45375" \
"4b0b30f7-5e83-4a5e-8434-d4d86040022a" \
"85514d3b-9f64-40aa-84c2-8a87ea37f66b" \
"cd374f59-31f1-41d6-9fd7-fbd96de9c845" \
"a4ffc550-998b-407d-9d27-fc9542808588" \
"bc70a3e5-745d-42b2-aa4e-24af0c2e0c1a" \
"6c254e7d-8989-4ef2-9437-4594481828ae" \
"b18165d6-41f6-4945-80d6-463297b6f052" \
"5d42fcbf-609d-4e33-9545-a256a4a6f6a9" \
"eadd5dd5-0945-4a46-9418-eb8ac429b55e" \
"81017fb2-76ef-4ce4-8443-a154236a28de" \
"40c8c634-3b82-40d8-88ef-389b40d05952" \
"2e3a1bad-e8d1-43aa-aa54-ac1b6bf671db")
UUID_INDEX=0

# Search for .uuid files in poppler directory, replace the UUID with the canned version
files=`debuerreotype-chroot $WD/chroot find "/usr/share/poppler/cMap/" "/usr/share/fonts" "/usr/local/share/fonts" -name ".uuid"`
echo "****Replacing UUIDs"
for f in $files; do
	echo $WD/chroot/$f
	cat $WD/chroot/$f
	debuerreotype-chroot $WD/chroot echo -n "${UUIDS[$UUID_INDEX]}" > $WD/chroot/$f
	cat $WD/chroot/$f
	UUID_INDEX=$((UUID_INDEX+1))
done

# END
