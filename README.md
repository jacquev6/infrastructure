My personal infrastructure, as code.

@todo Explain the situation and problem solved and why the 'push' pattern is the most practical in that situation.
@todo Link to the IAC page on Wiki, especially to the table listing popular software and their push/pull model.

Resources are created using [Terraform](https://www.terraform.io/).
Machines' configuration is managed using [Ansible](https://www.ansible.com/).
Everything is run in [Docker](https://www.docker.com/), both on client side and on servers.

Cluster:
- Kubernetes
- MinIO (s3-like)
- https://en.wikipedia.org/wiki/Nextcloud or https://en.wikipedia.org/wiki/OwnCloud
- Gluster (NFS)
  - https://blog.stephane-robert.info/post/raspberry-cluster-glusterfs-kubernetes/

Google "glusterfs vs minio" to get more candidates for distributed storage.
