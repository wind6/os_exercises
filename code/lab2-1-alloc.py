
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
