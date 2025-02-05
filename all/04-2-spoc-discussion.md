#lec9 虚存置换算法spoc练习

## 个人思考题
1. 置换算法的功能？

2. 全局和局部置换算法的不同？

3. 最优算法、先进先出算法和LRU算法的思路？

4. 时钟置换算法的思路？

5. LFU算法的思路？

6. 什么是Belady现象？

7. 几种局部置换算法的相关性：什么地方是相似的？什么地方是不同的？为什么有这种相似或不同？

8. 什么是工作集？

9. 什么是常驻集？

10. 工作集算法的思路？

11. 缺页率算法的思路？

12. 什么是虚拟内存管理的抖动现象？

13. 操作系统负载控制的最佳状态是什么状态？

## 小组思考题目

----
(1)（spoc）请证明为何LRU算法不会出现belady现象
证明：
		原理:因为小的物理页帧的栈包含于大数目的物理页帧的栈
		证明根据课堂老师给出的基础：
			来证明s(t) 始终包含于 s'(t)
			利用归纳法，假设 1<=i<=t-1 时 s(i)包含于s'(i)，现在要证s(t)依然包含于s'(t)
			(1) b(t)同时属于s(t)和s'(t)：此时s(t)和s'(t)都不发生变化，满足包含关系；
			(2) b(t)不属于s(t),属于s'(t)：s(t) 替换后，由于b(t)∈s(t)，所以s(t)包含于s'(t)
			(3)  (1)和(2)很容易证明，
				对于b(t)同时不属于s(t-1)和s'(t-1)的情况，我们依然按照视频里栈的方式对s(t-1)和s'(t-1)排序
				由于s(t-1)包含于s'(t-1),所以s(t-1)内每一个元素都存在于s'(t-1)中。
				现在两个栈都是按最后一次访问的时间的顺序来排列的，由于s(t)在进行替换时会替换s(t-1)里面最长时间没被访问的元素(栈底)，设为a,那么a显然也存在于s'(t-1)里面，并且它不一定是s'(t-1)的栈底。
					A. 当a是s'(t-1)的栈底时，s(t)和s'(t)替换的都是a, s(t) = s(t-1) - {a} + {b(t)} , s'(t) = s'(t-1) - {a} + {b(t)}
					B. 当a不是s'(t-1)的栈底是，则s'(t-1)的栈底c必然不属于s(t-1)，否则就会与a是s(t-1)的栈底矛盾（即c比a有更长的时间未被访问），此种情况下s(t)和s'(t)依然满足包含关系
			(4) 由归纳假设可以得知此种情况不存在

(2)（spoc）根据你的`学号 mod 4`的结果值，确定选择四种替换算法（0：LRU置换算法，1:改进的clock 页置换算法，2：工作集页置换算法，3：缺页率置换算法）中的一种来设计一个应用程序（可基于python, ruby, C, C++，LISP等）模拟实现，并给出测试。请参考如python代码或独自实现。
 - [页置换算法实现的参考实例](https://github.com/chyyuu/ucore_lab/blob/master/related_info/lab3/page-replacement-policy.py)

```
#! /usr/bin/env python

import sys
from optparse import OptionParser
import random
import math

def hfunc(index):
    if index == -1:
        return 'MISS'
    else:
        return 'HIT '

def vfunc(victim):
    if victim == -1:
        return '-'
    else:
        return str(victim)

#
# main program
#
parser = OptionParser()
parser.add_option('-a', '--addresses', default='-1',   help='a set of comma-separated pages to access; -1 means randomly generate',  action='store', type='string', dest='addresses')
parser.add_option('-p', '--policy', default='FIFO',    help='replacement policy: FIFO, LRU, OPT, CLOCK',                action='store', type='string', dest='policy')
parser.add_option('-b', '--clockbits', default=1,      help='for CLOCK policy, how many clock bits to use',                          action='store', type='int', dest='clockbits')
parser.add_option('-f', '--pageframesize', default='3',    help='size of the physical page frame, in pages',                                  action='store', type='string', dest='pageframesize')
parser.add_option('-s', '--seed', default='0',         help='random number seed',                                                    action='store', type='string', dest='seed')
parser.add_option('-N', '--notrace', default=False,    help='do not print out a detailed trace',                                     action='store_true', dest='notrace')
parser.add_option('-c', '--compute', default=False,    help='compute answers for me',                                                action='store_true', dest='solve')

(options, args) = parser.parse_args()

print 'ARG addresses', options.addresses
print 'ARG policy', options.policy
print 'ARG clockbits', options.clockbits
print 'ARG pageframesize', options.pageframesize
print 'ARG seed', options.seed
print 'ARG notrace', options.notrace
print ''

addresses   = str(options.addresses)
pageframesize   = int(options.pageframesize)
seed        = int(options.seed)
policy      = str(options.policy)
notrace     = options.notrace
clockbits   = int(options.clockbits)

random.seed(seed)

addrList = []
addrList = addresses.split(',')

if options.solve == False:
    print 'Assuming a replacement policy of %s, and a physical page frame of size %d pages,' % (policy, pageframesize)
    print 'figure out whether each of the following page references hit or miss'

    for n in addrList:
        print 'Access: %d  Hit/Miss?  State of Memory?' % int(n)
    print ''

else:
    if notrace == False:
        print 'Solving...\n'

    # init memory structure
    count = 0
    memory = []
    hits = 0
    miss = 0

    if policy == 'FIFO':
        leftStr = 'FirstIn'
        riteStr = 'Lastin '
    elif policy == 'LRU':
        leftStr = 'LRU'
        riteStr = 'MRU'
    elif policy == 'OPT' or  policy == 'CLOCK':
        leftStr = 'Left '
        riteStr = 'Right'
    else:
        print 'Policy %s is not yet implemented' % policy
        exit(1)

    # track reference bits for clock
    ref   = {}

    cdebug = False

    # need to generate addresses
    addrIndex = 0
    for nStr in addrList:
        # first, lookup
        n = int(nStr)
        try:
            idx = memory.index(n)
            hits = hits + 1
            if policy == 'LRU' :
                update = memory.remove(n)
                memory.append(n) # puts it on MRU side
        except:
            idx = -1
            miss = miss + 1

        victim = -1        
        if idx == -1:
            # miss, replace?
            # print 'BUG count, pageframesize:', count, pageframesize
            if count == pageframesize:
                # must replace
                if policy == 'FIFO' or policy == 'LRU':
                    victim = memory.pop(0)
                elif policy == 'CLOCK':
                    if cdebug:
                        print 'REFERENCE TO PAGE', n
                        print 'MEMORY ', memory
                        print 'REF (b)', ref
                    # hack: for now, do random
                    # victim = memory.pop(int(random.random() * count))
                    victim = -1
                    while victim == -1:
                        page = memory[int(random.random() * count)]
                        if cdebug:
                            print '  scan page:', page, ref[page]
                        if ref[page] >= 1:
                            ref[page] -= 1
                        else:
                            # this is our victim
                            victim = page
                            memory.remove(page)
                            break

                    # remove old page's ref count
                    if page in memory:
                        assert('BROKEN')
                    del ref[victim]
                    if cdebug:
                        print 'VICTIM', page
                        print 'LEN', len(memory)
                        print 'MEM', memory
                        print 'REF (a)', ref

                elif policy == 'OPT':
                    maxReplace  = -1
                    replaceIdx  = -1
                    replacePage = -1
                    # print 'OPT: access %d, memory %s' % (n, memory) 
                    # print 'OPT: replace from FUTURE (%s)' % addrList[addrIndex+1:]
                    for pageIndex in range(0,count):
                        page = memory[pageIndex]
                        # now, have page 'page' at index 'pageIndex' in memory
                        whenReferenced = len(addrList)
                        # whenReferenced tells us when, in the future, this was referenced
                        for futureIdx in range(addrIndex+1,len(addrList)):
                            futurePage = int(addrList[futureIdx])
                            if page == futurePage:
                                whenReferenced = futureIdx
                                break
                        # print 'OPT: page %d is referenced at %d' % (page, whenReferenced)
                        if whenReferenced >= maxReplace:
                            # print 'OPT: ??? updating maxReplace (%d %d %d)' % (replaceIdx, replacePage, maxReplace)
                            replaceIdx  = pageIndex
                            replacePage = page
                            maxReplace  = whenReferenced
                            # print 'OPT: --> updating maxReplace (%d %d %d)' % (replaceIdx, replacePage, maxReplace)
                    victim = memory.pop(replaceIdx)
                    # print 'OPT: replacing page %d (idx:%d) because I saw it in future at %d' % (victim, replaceIdx, whenReferenced)
            else:
                # miss, but no replacement needed (page frame not full)
                victim = -1
                count = count + 1

            # now add to memory
            memory.append(n)
            if cdebug:
                print 'LEN (a)', len(memory)
            if victim != -1:
                assert(victim not in memory)

        # after miss processing, update reference bit
        if n not in ref:
            ref[n] = 1
        else:
            ref[n] += 1
            if ref[n] > clockbits:
                ref[n] = clockbits
        
        if cdebug:
            print 'REF (a)', ref

        if notrace == False:
            print 'Access: %d  %s %s -> %12s <- %s Replaced:%s [Hits:%d Misses:%d]' % (n, hfunc(idx), leftStr, memory, riteStr, vfunc(victim), hits, miss)
        addrIndex = addrIndex + 1
        
    print ''
    print 'FINALSTATS hits %d   misses %d   hitrate %.2f' % (hits, miss, (100.0*float(hits))/(float(hits)+float(miss)))
    print ''

    
    
    








```
## 扩展思考题
（1）了解LIRS页置换算法的设计思路，尝试用高级语言实现其基本思路。此算法是江松博士（导师：张晓东博士）设计完成的，非常不错！

参考信息：

 - [LIRS conf paper](http://www.ece.eng.wayne.edu/~sjiang/pubs/papers/jiang02_LIRS.pdf)
 - [LIRS journal paper](http://www.ece.eng.wayne.edu/~sjiang/pubs/papers/jiang05_LIRS.pdf)
 - [LIRS-replacement ppt1](http://dragonstar.ict.ac.cn/course_09/XD_Zhang/(6)-LIRS-replacement.pdf)
 - [LIRS-replacement ppt2](http://www.ece.eng.wayne.edu/~sjiang/Projects/LIRS/sig02.ppt)
