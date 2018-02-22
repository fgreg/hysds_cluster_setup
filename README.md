HySDS Cluster Provisioner
=========================

Set of shell and fabric scripts to help provision a HySDS cluster.


Installation
------------
As _ops_ run:
```
cd ~
git clone https://github.jpl.nasa.gov/hysds-org/hysds_cluster_setup
cd hysds_cluster_setup
sds configure
cp cluster.py.example cluster.py
```
Update *cluster.py* with additional code that needs to be provisioned on the workers.
