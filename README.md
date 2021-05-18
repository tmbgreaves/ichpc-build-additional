# Fluidity/FETCH2 additional build details for IC HPC

Updated: 2020-05-04

If you have been directed here from the IC HPC ese-fluidity-dev module, please make use of the five patches and build script to get a working Fluidity build on CX1 or CX2.

The build script needs some edits, particularly to variables defining your build environment, which have been flagged in comments. You may also want to remove the install command and following script backup and module write if you're just running from a local build directory.

The patches deal with making sure Fluidity only uses the ese module versions of netcdf and hdf5 without generating conflicts against the system versions, and the vtk patches deal with issues building against VTK9, fixing the vtkfortran build and working around issues with cmake automagic by directly injecting the required library list into Makefiles.

# Runtime requirements for using CX3

Users report that the following are required in PBS scripts for successful running on IC HPC, specifically using CX3 nodes as CX1 and CX2 hardware has known issues with Fluidity.

```
Wall time: 72:00:00
Nodes: 10 (worked for 13 as well)
CPUs: 32
Threads: 1
Memory 124gb
```

It's also important to add the following line in your PBS script:

```
#PBS -l avx2=true
```
