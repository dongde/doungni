
#jenkins maintain
1
    [10/28/15, 23:50:45] doungni: @mingli，晚上 deployBasicCookbooks 报了一个 autotest-auth的错误，你明儿改一下
    [10/28/15, 23:50:58] doungni: 错误代码：
    19:46:58        Running handlers:
    19:46:58        [2015-10-28T19:45:51+08:00] ERROR: Running exception handlers
    19:46:58        Running handlers complete
    19:46:58        [2015-10-28T19:45:51+08:00] ERROR: Exception handlers complete
    19:46:58        Chef Client failed. 42 resources updated in 16 minutes 36 seconds
    19:46:58        [2015-10-28T19:45:51+08:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
    19:46:58        [2015-10-28T19:45:51+08:00] ERROR: ark[jmeter] (autotest-auth::jmeter_default line 28) had an error: Chef::Exceptions::ContentLengthMismatch: remote_file[/tmp/kitchen/cache/jmeter-2.13.tgz] (/tmp/kitchen/cache/cookbooks/ark/providers/default.rb line 45) had an error: Chef::Exceptions::ContentLengthMismatch: Response body length 16919730 does not match HTTP Content-Length header 35326648.
    19:46:58        [2015-10-28T19:45:51+08:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
    19:46:59 >>>>>> Converge failed on instance <default-ubuntu-1404>.
    [10/28/15, 23:51:22] doungni: http://50.198.76.249:443/job/DockerDeployBasicCookbooks/398/consoleFull
    [10/28/15, 23:54:09] denny: 孙康，你先file一个ticket吧。

    这个问题有代表意义
    [10/28/15, 23:55:51] doungni: 我感觉是mingli做的jmeter代码有问题还是什么的，之前貌似没有出现过，我一会儿发一个ticket上去
    [10/28/15, 23:57:59] denny: Jenkins maintainer的首要职责不是分析和解决问题， 而只需要给我们一个清晰的picture：
    - 现在CI有哪些task是失败的
    - 每一个新的问题，提交一个ticket
    - 每个ticket都有合适的人在跟进。
    [10/28/15, 23:58:51] doungni: Ok了，@mingli，你明儿解决这个问题的时候，俺跟紧学习一下，加快俺对chef的处理job
    [10/28/15, 23:58:54] denny: 简单说，如果这个问题以前没有出现过，那么Jenkins maintainer第一件要做的事情是提交一个ticket
    [10/28/15, 23:59:21] denny: 然后，才是其它，例如找人跟进，分析原因等等。
    [10/28/15, 23:59:31] doungni: 恩，3q，谢谢denny，再次提醒，俺确实应该把这个好习惯留下
    [10/28/15, 23:59:38] denny: 甚至分析原因的职责不在Jenkins maintainer。
    [10/29/15, 00:00:06] doungni: 哦
    [10/29/15, 00:01:00] denny: 我们想达到的效果是：
    - 每一次CI报了错，都应该是代码或其它团队的问题，而不是infrastructure本身的问题
    - 我们大家比较清楚CI的整体状况
    - 每天jenkins maintainer在Jenkins上的时间花费不超过半个小时
    [10/29/15, 00:03:42] denny: 尤其是第二点，不清楚其它同事，老实讲，我现在属于比较懵懂的状态。只知道一直没过，但不知道是怎么回事。

    当然，如果愿意跟进去分析每一个出错原因，那当然是很好的。但注意：那不是Jenkins maintainer的维度。也绝对不是他/她的首要职责。
    [10/29/15, 00:06:09] denny: 给大家一个Jenkins的当前open issue list, 这个是Jenkins maintainer的首要做的事情，或者说是唯一的事情。
