---
layout: default
title: "CephFS Namespace Affinity"
author: Michael Sevilla
---

We want to streth Mantle a little; how does Mantle work for mixed workloads and
can it be used to balance other types of resources. To do this, we will look at
the intersection of Docker containers and HPC workloads.

One idea for improving the performance of HPC workloads is to enforce isolation
at the file system layer. HPC applications usually operate independently (i.e.
they are not general purpose applications) and the file system can afford to
isolate the work streams. One approach is to have the application check out the
part of the file system namespace that it will be using. We want to see how
CephFS does in a scenario where:

- clients check out file system namespace subtrees

- subtrees migrate to the clients

The success of this approach depends on the benefits of namespace affinity so
we must answer the following question: does an application perform better when
its namespace is local?

## Benchmarks

#### Experiment 1: metadata writes

Here we do 100,0000 creates in the same directory. Assuming that we have turned
off the balancing with `mds_bal_interval = -1` and that metadata server 0 is
issdm-12, we test namespace affinity with:

```bash
for i in 0 1 2; do 
  ./ansible-playbook.sh -e nfiles=100000 ../workloads/metawrites.yml
  ./ansible-playbook.sh -e nfiles=100000 ../workloads/metawrites2.yml
done
```

where `metawrites.yml` does creates with the client on issdm-12 and
`metawrites2.yml` does creates with the client on issdm-15. Unfortunately, the
results show:

```bash
~/namespace-affinity$ cat results/mdtest-issdm-12* | grep "File creation"
   File creation     :        428.100        428.100        428.100          0.000
   File creation     :        417.181        417.181        417.181          0.000
   File creation     :        418.119        418.119        418.119          0.000
   File creation     :        417.150        417.150        417.150          0.000
~/namespace-affinity$ cat results/mdtest-issdm-15* | grep "File creation"
   File creation     :        437.797        437.797        437.797          0.000
   File creation     :        439.146        439.146        439.146          0.000
   File creation     :        438.780        438.780        438.780          0.000
   File creation     :        437.392        437.392        437.392          0.000
```

What the fuck is going on? How does a client on *another* node get better
performance? It seems that we are seeing a chain replication phenomenon, where
splitting up the work improves performance. To get a rough idea of how much
work each server is doing, we can look at CPU utilization. If you are following
along at home, my monitor playbook looks like:

```yaml
- hosts: graphite
  become: True
  roles: 
    - monitor/graphite

- hosts: osds
  become: True
  roles:
    - monitor/collectl

- hosts: mdss
  become: True
  roles:
    - monitor/collectl
    - ceph/ceph-stats
```

and my collectl arguments in the `mdss` and `osds` variable files are
`-scn -i 1` and `-sd -i 1`, respectively. Great. On to the results!

![Utilization](/images/posts/namespace-affinity-utilization.png)

We see two jobs here:

Job    | client   | metadata server
-------|----------|----------------
local  | issdm-12 | issdm-12
remote | issdm-15 | issdm-12

Some observations:

- Total CPU utilization is the same but in "local" the usage is higher per
  core.

- Network utilization is lower in "local" and in "remote" we see *more*
  outgoing network IO, which is made up of:
 
  > Network IO = response to client + logging

- Disk utilization is higher for the "remote" experiment.

These graphs suggest that the "remote" setup is doing **more** work and does
not explain why performance is better than "local". Testing without caching did
not change the results. It seems that splitting up work amongst more cores
improves create performance because each core is doing less work and context
switching.

Some ideas for reducing CPU utilization and context switching:

- try a different workload

- use the Ceph kernel client

- pin the CPU to a container

Some ideas:

- caching eliminates network activity so the extra cycles that the metadata
  server takes from the client is pure overhead (logging, segment cleaning, etc.).
  Idea: remove the caching to force round trips.

- there is excessive batching in the "local" case and the batching
  infrastructure is slower (to pursue this, find a new metric that shows this
  batching; e.g., segments)

- segment cleaning takes time and the MDS can only do so much work (evident by
  the CPU utilzation). 

- try moving the directory issdm-15 and then doing that experiment -- maybe
  MDS0 has a shit ton of stuff to do.

- maybe trying using 3 servers to do the work and show how roping off MORE
  servers and splitting work that way is not always the best.














#### Other Experimnets

Reads: 100,0000 reads in same directory

Experiments:

Namespace local
Namespace remote
Namespace split up



