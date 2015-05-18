# 同步互斥(lec 18) spoc 思考题


- 有"spoc"标记的题是要求拿清华学分的同学要在实体课上完成，并按时提交到学生对应的ucore_code和os_exercises的git repo上。

## 个人思考题

### 基本理解
 - 什么是信号量？它与软件同步方法的区别在什么地方？
 - 什么是自旋锁？它为什么无法按先来先服务方式使用资源？
 - 下面是一种P操作的实现伪码。它能按FIFO顺序进行信号量申请吗？
```
 while (s.count == 0) {  //没有可用资源时，进入挂起状态；
        调用进程进入等待队列s.queue;
        阻塞调用进程;
}
s.count--;              //有可用资源，占用该资源； 
```

> 参考回答： 它的问题是，不能按FIFO进行信号量申请。
> 它的一种出错的情况
```
一个线程A调用P原语时，由于线程B正在使用该信号量而进入阻塞状态；注意，这时value的值为0。
线程B放弃信号量的使用，线程A被唤醒而进入就绪状态，但没有立即进入运行状态；注意，这里value为1。
在线程A处于就绪状态时，处理机正在执行线程C的代码；线程C这时也正好调用P原语访问同一个信号量，并得到使用权。注意，这时value又变回0。
线程A进入运行状态后，重新检查value的值，条件不成立，又一次进入阻塞状态。
至此，线程C比线程A后调用P原语，但线程C比线程A先得到信号量。
```

### 信号量使用

 - 什么是条件同步？如何使用信号量来实现条件同步？
 - 什么是生产者-消费者问题？
 - 为什么在生产者-消费者问题中先申请互斥信息量会导致死锁？

### 管程

 - 管程的组成包括哪几部分？入口队列和条件变量等待队列的作用是什么？
 - 为什么用管程实现的生产者-消费者问题中，可以在进入管程后才判断缓冲区的状态？
 - 请描述管程条件变量的两种释放处理方式的区别是什么？条件判断中while和if是如何影响释放处理中的顺序的？

### 哲学家就餐问题

 - 哲学家就餐问题的方案2和方案3的性能有什么区别？可以进一步提高效率吗？

### 读者-写者问题

 - 在读者-写者问题的读者优先和写者优先在行为上有什么不同？
 - 在读者-写者问题的读者优先实现中优先于读者到达的写者在什么地方等待？
 
## 小组思考题

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 3b4649073e248f188eacbe510283310fe1d2627e
1. （spoc） 每人用python threading机制用信号量和条件变量两种手段分别实现[47个同步问题](07-2-spoc-pv-problems.md)中的一题。向勇老师的班级从前往后，陈渝老师的班级从后往前。请先理解[]python threading 机制的介绍和实例](https://github.com/chyyuu/ucore_lab/tree/master/related_info/lab7/semaphore_condition)

>周昊 2012011326
>
>11.在一间酒吧里有三个音乐爱好者队列，第一队的音乐爱好者只有随身听，第二队的只有音乐磁带，第三队只有电池。而要听音乐就必须随身听，音乐磁带和电池这三种物品俱全。酒吧老板依次出售这三种物品中的任意两种。当一名音乐爱好者得到这三种物品并听完一首乐曲后，酒吧老板才能再一次出售这三种物品中的任意两种。于是第二名音乐爱好者得到这三种物品，并开始听乐曲。全部买卖就这样进行下去。试用P，V操作正确解决这一买卖。
 
code-semaphore

```
#coding=utf-8
#semaphore
import threading  
import random  
import time  

class Producer(threading.Thread):
    goods = [1, 2, 3]

    def __init__(self, threadName, semaphore0, semaphore1, semaphore2, semaphore3):
        threading.Thread.__init__(self,name=threadName)  
        self.semaphore0 = semaphore0
        self.semaphore1 = semaphore1
        self.semaphore2 = semaphore2
        self.semaphore3 = semaphore3

    def run(self):
        while True:
            self.semaphore0.acquire()
            good = random.randrange(1, 4)
            if good == 1:
                print 'Produce Tape, Battery'
                self.semaphore1.release()
            elif good == 2:
                print 'Produce Walkman, Battery'
                self.semaphore2.release()
            else:
                print 'Produce Walkman, Tape'
                self.semaphore3.release()

class Listener(threading.Thread):
    
    def __init__(self, threadName, need, semaphore0, semaphore):
        threading.Thread.__init__(self,name=threadName)  
        self.need = need
        self.semaphore0 = semaphore0
        self.semaphore = semaphore
        
    def run(self):
        while True:
            self.semaphore.acquire()
            if self.need == 1:
                print self.getName()+': Buy Tape, Battery. Listening'
            elif self.need == 2:
                print self.getName()+': Buy Walkman, Battery. Listening'
            else:
                print self.getName()+': Buy Walkman, Tape. Listening'
            time.sleep(2)
            self.semaphore0.release()
            

threads=[]
semaphore0 = threading.Semaphore(1)
semaphore1 = threading.Semaphore(0)
semaphore2 = threading.Semaphore(0)
semaphore3 = threading.Semaphore(0)

threads.append(Producer("Producer", semaphore0, semaphore1, semaphore2, semaphore3))
threads.append(Listener("Listener1", 1, semaphore0, semaphore1))
threads.append(Listener("Listener2", 2, semaphore0, semaphore2))
threads.append(Listener("Listener3", 3, semaphore0, semaphore3))

for thread in threads: 
   thread.start()
```


code-condition

```
#coding=utf-8
#condition
import threading  
import random  
import time  

condition = threading.Condition()
product = 0
class Producer(threading.Thread):
    goods = [1, 2, 3]

    def __init__(self, threadName):
        threading.Thread.__init__(self,name=threadName)  
        
    def run(self):
        global condition, product
        while True:
            if condition.acquire():
                if product == 0:
                    product = random.randrange(1, 4)
                    if product == 1:
                        print 'Produce Tape, Battery'
                    elif product == 2:
                        print 'Produce Walkman, Battery'
                    else:
                        print 'Produce Walkman, Tape'
                    condition.notifyAll()
                else:
                    condition.wait()
                condition.release()
                
class Listener(threading.Thread):
    
    def __init__(self, threadName, need):
        threading.Thread.__init__(self,name=threadName)  
        self.need = need
               
    def run(self):
        global condition, product
        while True:
            if condition.acquire():
                if product == self.need:
                    if self.need == 1:
                        print self.getName()+': Buy Tape, Battery. Listening'
                    elif self.need == 2:
                        print self.getName()+': Buy Walkman, Battery. Listening'
                    else:
                        print self.getName()+': Buy Walkman, Tape. Listening'
                    product = 0
                    time.sleep(2)
                    condition.notifyAll()
                else:
                    condition.wait()
                condition.release()

threads=[]
semaphore0 = threading.Semaphore(1)
semaphore1 = threading.Semaphore(0)
semaphore2 = threading.Semaphore(0)
semaphore3 = threading.Semaphore(0)

threads.append(Producer("Producer"))
threads.append(Listener("Listener1", 1))
threads.append(Listener("Listener2", 2))
threads.append(Listener("Listener3", 3))

for thread in threads: 
   thread.start() 
<<<<<<< HEAD
 ```
=======
1. （spoc） 每人用python threading机制用信号量和条件变量两种手段分别实现[47个同步互斥问题](07-2-spoc-pv-problems.md)中的一题。向勇老师的班级从前往后，陈渝老师的班级从后往前。请先理解[]python threading 机制的介绍和实例](https://github.com/chyyuu/ucore_lab/tree/master/related_info/lab7/semaphore_condition)

2. (spoc)设计某个方法，能够动态检查出对于两个或多个进程的同步互斥问题执行中，没有互斥问题，能够同步等，以说明实现的正确性。
>>>>>>> c42e67792e804a57bfcbf5f509328e840eb70c29
=======
 ```
>>>>>>> 3b4649073e248f188eacbe510283310fe1d2627e
