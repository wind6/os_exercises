# lec5 SPOC思考题


NOTICE
- 有"w3l1"标记的题是助教要提交到学堂在线上的。
- 有"w3l1"和"spoc"标记的题是要求拿清华学分的同学要在实体课上完成，并按时提交到学生对应的git repo上。
- 有"hard"标记的题有一定难度，鼓励实现。
- 有"easy"标记的题很容易实现，鼓励实现。
- 有"midd"标记的题是一般水平，鼓励实现。


## 个人思考题
---

请简要分析最优匹配，最差匹配，最先匹配，buddy systemm分配算法的优势和劣势，并尝试提出一种更有效的连续内存分配算法 (w3l1)

```
  + 采分点：说明四种算法的优点和缺点
  - 答案没有涉及如下3点；（0分）
  - 正确描述了二种分配算法的优势和劣势（1分）
  - 正确描述了四种分配算法的优势和劣势（2分）
  - 除上述两点外，进一步描述了一种更有效的分配算法（3分）
 ```
- [x]  

>  优点： 最先匹配：实现简单，高地址空间有大块空分区，释放分区很快。 最差匹配：适合中等大小分配较多的情况，不会出现太多的小碎片。 最佳匹配：可避免过多的空闲大分区被拆分，外部碎片很小。 buddy system：不会产生太多的小碎片，对大、中、小空间分配都很均衡，效率也较高（O(logN)），空间释放也比较快（O(logN))。
>  
>  缺点： 最先匹配：会产生大量外部碎片，分配大块空间时效率低（分区的list太长）。 最差匹配：释放分区较慢，容易破坏大的空闲分区，同样会有外部碎片。 最佳匹配：容易产生许多无用的小碎片，分配或释放后重新维护顺序需要一定的开销，并且释放分区的合并与最差匹配一样慢。 buddy system：有时候会产生较大的内部碎片，对于恰好比2的幂次方大一点点的空间需求，空间浪费比较严重 (比如65KB的需求会浪费63KB的内存空间)。
>  
>  改进最先匹配算法，可以考虑记录下上一次分配内存后的地址，每次分配从上一次分配内存后的地址开始搜索，直至找到一个能满足需求的空闲分区，这样可以使内存使用的更为平均，但也使得最先匹配算法的“高地址空间有大块空分区”的优点被削弱。


## 小组思考题

请参考ucore lab2代码，采用`struct pmm_manager` 根据你的`学号 mod 4`的结果值，选择四种（0:最优匹配，1:最差匹配，2:最先匹配，3:buddy systemm）分配算法中的一种或多种，在应用程序层面(可以 用python,ruby,C++，C，LISP等高语言)来实现，给出你的设思路，并给出测试用例。 (spoc)

我的学号为2012011326，以下为我用python实现的最先匹配算法

```
class mem:
    free = 1
    prev = 0
    next = 0

    def __init__(self, size = 512):
        self.size = size


class mem_list:
    stack = []
    
    def __init__(self):
        self.head = mem()
        self.stack.append(self.head)
        for i in range(15):
            self.insert_mem(mem(), self.stack[-1])
            if i % 2 == 0:
                self.stack[-1].free = 0;

    def insert_mem(self, block, prev, next = 0):
        prev.next = block
        block.prev = prev
        if(next != 0):
            next.prev = block
            block.next = next
        self.stack.append(block)

    def delete_mem(self, block):
        prev = block.prev
        next = block.next
        if(prev != 0):
            prev.next = next
        if(next != 0):
            next.prev = prev
        del block


    def set_mem(self, size):
        elem = self.head
        while 1:
            if elem.free == 1 and elem.size >= size:
                elem.free = 0
                newmem = mem(elem.size - size)
                elem.size = size
                self.insert_mem(newmem, elem, elem.next)
                break
            else:
                if elem.next == 0:
                    print "no memory can be allocated!"
                    break
                else:
                    elem = elem.next

    def free_mem(self, block):
        block.free = 1
        if block.next != 0 and block.prev != 0 and block.next.free == 1 and block.prev.free == 1:
            block.prev.size = block.size + block.prev.size + block.next.size 
            self.delete_mem(block.next)
            self.delete_mem(block)
        elif block.next != 0 and block.next.free == 1:
            block.size = block.size + block.next.size 
            self.delete_mem(block.next)
        elif block.prev != 0 and block.prev.free == 1:
            block.prev.size = block.size + block.prev.size 
            self.delete_mem(block)



    def print_mem(self):
        elem = self.head
        index = 0
        while 1:
            print "mem"+str(index)+" size="+str(elem.size)+ (" used" if elem.free == 0 else " free")
            if elem.next == 0:
                break
            elem = elem.next
            index = index+1

buffer = mem_list()
buffer.set_mem(300)
buffer.set_mem(444)
buffer.set_mem(666)
buffer.free_mem(buffer.stack[0])
buffer.free_mem(buffer.stack[1])
buffer.free_mem(buffer.stack[2])
buffer.print_mem()
```
另附上之前自己曾用汇编写过的最优分配算法（allocate.s）

```
.section .data
#This points to the beginning of the memory we are managing
heap_begin:
	.long 0
#This points to one location past the memory we are managing
current_break:
	.long 0
#This points to one location past the memory we are managing
best_block_location:
	.long 0
#This points to one location past the memory we are managing
best_block_size:
	.long 2147483647
#size of space for memory region header
.equ HEADER_SIZE, 8  
#Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0 
#Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4  
#This is the number we will use to mark space that has been given out
.equ UNAVAILABLE, 0 
#This is the number we will use to mark space that has been returned, and is available for giving
.equ AVAILABLE, 1  
#system call number for the break                   
.equ SYS_BRK, 45
#system call
.equ LINUX_SYSCALL, 0x80 #make system calls easier to read


.section .text
.globl allocate_init
.type allocate_init,@function
allocate_init:
	pushl %ebp
	movl %esp, %ebp
	
	#If the brk system call is called with 0 in %ebx, it returns the last valid usable address
	movl $SYS_BRK, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL
	incl %eax #%eax now has the last valid address movl %eax, current_break #store the current break
	movl %eax, heap_begin
	movl %ebp, %esp #exit the function 
	popl %ebp
	ret


.globl allocate
.type allocate, @function 
.equ ST_MEM_SIZE, 8 #stack position of the memory size to allocate

allocate:

	pushl %ebp
	movl %esp, %ebp
	movl ST_MEM_SIZE(%ebp), %ecx #%ecx will hold the size

	#we are looking for (which is the first #and only parameter)
	movl heap_begin, %eax 	 #%eax will hold the search location 
	movl current_break, %ebx #%ebx will hold the current break
	movl $2147483647, best_block_size
	movl $0, best_block_location
	
loop_begin:
	cmpl %ebx, %eax #we iterate through memory regions
	je move_break	#need more memory if these are equal
	
	 
	#grab the size of this memory
	movl HDR_SIZE_OFFSET(%eax), %edx
	cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
	je next_location	#If unavailable, go to the next
    cmpl %edx, %ecx		#If available, check the size
    jle search_best		#big enough, go to search_best
	
next_location:
	addl $HEADER_SIZE, %eax 
	addl %edx, %eax		#The total size of the memory 
	jmp loop_begin		#go look at the next location
	

search_best:
	cmpl best_block_size, %edx
	jle update_best_block
	jmp next_location

update_best_block:
	movl %edx, best_block_size
	movl %eax, best_block_location
	jmp next_location
	
allocate_here:
	#if we’ve made it here, that means that the region header of the #region to allocate is in %eax, mark space as unavailable
	movl best_block_location, %eax
	movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
	addl $HEADER_SIZE, %eax #move %eax to the usable memory
	movl %ebp, %esp 
	popl %ebp
	ret
	
move_break:
	cmpl $0, best_block_location
	jne allocate_here
	addl $HEADER_SIZE, %ebx #add space for the headers structure
	addl %ecx, %ebx			#add space to the break for the data requested
	pushl %eax				#save needed registers 
	movl $SYS_BRK, %eax 	#reset the break
	int $LINUX_SYSCALL 
	
	#error check
	cmpl current_break, %eax
	je error_occur
	
	#set this memory as unavailable, since we’re about to give it away
	popl %eax 
	movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
	movl %ecx, HDR_SIZE_OFFSET(%eax)	#set the size of the memory
	addl $HEADER_SIZE, %eax				#move %eax to the actual start of usable memory.
	movl %ebx, current_break			#save the new break
	movl %ebp, %esp 
	popl %ebp
	ret
	
error_occur:
	leave
	ret

```

最优分配算法（deallocate.s）

```
.section .data
#This points to the beginning of the memory we are managing
heap_begin:
	.long 0
#This points to one location past the memory we are managing
current_break:
	.long 0
#size of space for memory region header
.equ HEADER_SIZE, 8  
#Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0 
#Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4  
#This is the number we will use to mark space that has been given out
.equ UNAVAILABLE, 0 
#This is the number we will use to mark space that has been returned, and is available for giving
.equ AVAILABLE, 1  
#system call number for the break                   
.equ SYS_BRK, 45
#system call
.equ LINUX_SYSCALL, 0x80 #make system calls easier to read

.section .text
.globl deallocate
.type deallocate,@function 
.equ ST_MEMORY_SEG, 4
deallocate:
	movl ST_MEMORY_SEG(%esp), %ecx	
	movl %ecx, %eax
	#get the pointer to the real beginning of the memory 
	subl $HEADER_SIZE, %ecx
	#look for its neighbor's condition
	addl HDR_SIZE_OFFSET(%ecx), %eax

loop:
	movl  HDR_AVAIL_OFFSET(%eax), %edx 
	test  %edx, %edx
	je 	  end_loop	
	addl  HDR_SIZE_OFFSET(%eax), %eax
	addl  $HEADER_SIZE, %eax
	jmp   loop

end_loop:
	#set the available flag
	movl  $AVAILABLE, HDR_AVAIL_OFFSET(%ecx)
	subl  %ecx, %eax
	subl  $HEADER_SIZE, %eax
	movl  %eax, HDR_SIZE_OFFSET(%ecx)
	ret 
```

--- 

## 扩展思考题

阅读[slab分配算法](http://en.wikipedia.org/wiki/Slab_allocation)，尝试在应用程序中实现slab分配算法，给出设计方案和测试用例。

## “连续内存分配”与视频相关的课堂练习

### 5.1 计算机体系结构和内存层次
MMU的工作机理？

- [x]  

>  http://en.wikipedia.org/wiki/Memory_management_unit

L1和L2高速缓存有什么区别？

- [x]  

>  http://superuser.com/questions/196143/where-exactly-l1-l2-and-l3-caches-located-in-computer
>  Where exactly L1, L2 and L3 Caches located in computer?

>  http://en.wikipedia.org/wiki/CPU_cache
>  CPU cache

### 5.2 地址空间和地址生成
编译、链接和加载的过程了解？

- [x]  

>  

动态链接如何使用？

- [x]  

>  


### 5.3 连续内存分配
什么是内碎片、外碎片？

- [x]  

>  

为什么最先匹配会越用越慢？

- [x]  

>  

为什么最差匹配会的外碎片少？

- [x]  

>  

在几种算法中分区释放后的合并处理如何做？

- [x]  

>  

### 5.4 碎片整理
一个处于等待状态的进程被对换到外存（对换等待状态）后，等待事件出现了。操作系统需要如何响应？

- [x]  

>  

### 5.5 伙伴系统
伙伴系统的空闲块如何组织？

- [x]  

>  

伙伴系统的内存分配流程？

- [x]  

>  

伙伴系统的内存回收流程？

- [x]  

>  

struct list_entry是如何把数据元素组织成链表的？

- [x]  

>  



