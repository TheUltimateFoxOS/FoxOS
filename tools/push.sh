function push_dir {
	(
		cd $1
		echo "Pushing $1"
		git push origin HEAD:main || echo "Failed to push $1"
	)
}

push_dir FoxOS-kernel
push_dir FoxOS-programs/libfoxos
push_dir FoxOS-programs/libtinf
push_dir FoxOS-programs/libc
push_dir FoxOS-programs
push_dir .