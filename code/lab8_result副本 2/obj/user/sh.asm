
obj/__user_sh.out:     file format elf32-i386


Disassembly of section .text:

00800020 <opendir>:
#include <error.h>
#include <unistd.h>

DIR dir, *dirp=&dir;
DIR *
opendir(const char *path) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	53                   	push   %ebx
  800024:	83 ec 34             	sub    $0x34,%esp

    if ((dirp->fd = open(path, O_RDONLY)) < 0) {
  800027:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80002d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800034:	00 
  800035:	8b 45 08             	mov    0x8(%ebp),%eax
  800038:	89 04 24             	mov    %eax,(%esp)
  80003b:	e8 b8 00 00 00       	call   8000f8 <open>
  800040:	89 03                	mov    %eax,(%ebx)
  800042:	8b 03                	mov    (%ebx),%eax
  800044:	85 c0                	test   %eax,%eax
  800046:	79 02                	jns    80004a <opendir+0x2a>
        goto failed;
  800048:	eb 44                	jmp    80008e <opendir+0x6e>
    }
    struct stat __stat, *stat = &__stat;
  80004a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80004d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (fstat(dirp->fd, stat) != 0 || !S_ISDIR(stat->st_mode)) {
  800050:	a1 00 30 80 00       	mov    0x803000,%eax
  800055:	8b 00                	mov    (%eax),%eax
  800057:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80005a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 4a 01 00 00       	call   8001b0 <fstat>
  800066:	85 c0                	test   %eax,%eax
  800068:	75 24                	jne    80008e <opendir+0x6e>
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	8b 00                	mov    (%eax),%eax
  80006f:	25 00 70 00 00       	and    $0x7000,%eax
  800074:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800079:	75 13                	jne    80008e <opendir+0x6e>
        goto failed;
    }
    dirp->dirent.offset = 0;
  80007b:	a1 00 30 80 00       	mov    0x803000,%eax
  800080:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    return dirp;
  800087:	a1 00 30 80 00       	mov    0x803000,%eax
  80008c:	eb 05                	jmp    800093 <opendir+0x73>

failed:
    return NULL;
  80008e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800093:	83 c4 34             	add    $0x34,%esp
  800096:	5b                   	pop    %ebx
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <readdir>:

struct dirent *
readdir(DIR *dirp) {
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 18             	sub    $0x18,%esp
    if (sys_getdirentry(dirp->fd, &(dirp->dirent)) == 0) {
  80009f:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a2:	8d 50 04             	lea    0x4(%eax),%edx
  8000a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a8:	8b 00                	mov    (%eax),%eax
  8000aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ae:	89 04 24             	mov    %eax,(%esp)
  8000b1:	e8 03 07 00 00       	call   8007b9 <sys_getdirentry>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	75 08                	jne    8000c2 <readdir+0x29>
        return &(dirp->dirent);
  8000ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8000bd:	83 c0 04             	add    $0x4,%eax
  8000c0:	eb 05                	jmp    8000c7 <readdir+0x2e>
    }
    return NULL;
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <closedir>:

void
closedir(DIR *dirp) {
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 18             	sub    $0x18,%esp
    close(dirp->fd);
  8000cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d2:	8b 00                	mov    (%eax),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 5e 00 00 00       	call   80013a <close>
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <getcwd>:

int
getcwd(char *buffer, size_t len) {
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 18             	sub    $0x18,%esp
    return sys_getcwd(buffer, len);
  8000e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 a1 06 00 00       	call   800797 <sys_getcwd>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <open>:
#include <stat.h>
#include <error.h>
#include <unistd.h>

int
open(const char *path, uint32_t open_flags) {
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
    openstep = 0;
  8000fe:	c7 05 24 30 80 00 00 	movl   $0x0,0x803024
  800105:	00 00 00 
    cprintf("%d [user_open]\n", openstep++);
  800108:	a1 24 30 80 00       	mov    0x803024,%eax
  80010d:	8d 50 01             	lea    0x1(%eax),%edx
  800110:	89 15 24 30 80 00    	mov    %edx,0x803024
  800116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011a:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  800121:	e8 df 02 00 00       	call   800405 <cprintf>
    return sys_open(path, open_flags);
  800126:	8b 45 0c             	mov    0xc(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	8b 45 08             	mov    0x8(%ebp),%eax
  800130:	89 04 24             	mov    %eax,(%esp)
  800133:	e8 6a 05 00 00       	call   8006a2 <sys_open>
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    

0080013a <close>:

int
close(int fd) {
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 18             	sub    $0x18,%esp
    return sys_close(fd);
  800140:	8b 45 08             	mov    0x8(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 79 05 00 00       	call   8006c4 <sys_close>
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <read>:

int
read(int fd, void *base, size_t len) {
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 18             	sub    $0x18,%esp
    
    return sys_read(fd, base, len);
  800153:	8b 45 10             	mov    0x10(%ebp),%eax
  800156:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 73 05 00 00       	call   8006df <sys_read>
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <write>:

int
write(int fd, void *base, size_t len) {
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 18             	sub    $0x18,%esp
    // cprintf("[user_write]\n");
    return sys_write(fd, base, len);
  800174:	8b 45 10             	mov    0x10(%ebp),%eax
  800177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 7b 05 00 00       	call   800708 <sys_write>
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <seek>:

int
seek(int fd, off_t pos, int whence) {
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 18             	sub    $0x18,%esp
    return sys_seek(fd, pos, whence);
  800195:	8b 45 10             	mov    0x10(%ebp),%eax
  800198:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 83 05 00 00       	call   800731 <sys_seek>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <fstat>:

int
fstat(int fd, struct stat *stat) {
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
    return sys_fstat(fd, stat);
  8001b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 92 05 00 00       	call   80075a <sys_fstat>
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <fsync>:

int
fsync(int fd) {
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 18             	sub    $0x18,%esp
    return sys_fsync(fd);
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 a1 05 00 00       	call   80077c <sys_fsync>
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <dup2>:

int
dup2(int fd1, int fd2) {
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	83 ec 18             	sub    $0x18,%esp
    return sys_dup(fd1, fd2);
  8001e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 e6 05 00 00       	call   8007db <sys_dup>
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <transmode>:

static char
transmode(struct stat *stat) {
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
    uint32_t mode = stat->st_mode;
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	8b 00                	mov    (%eax),%eax
  800202:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (S_ISREG(mode)) return 'r';
  800205:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800208:	25 00 70 00 00       	and    $0x7000,%eax
  80020d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800212:	75 07                	jne    80021b <transmode+0x24>
  800214:	b8 72 00 00 00       	mov    $0x72,%eax
  800219:	eb 5d                	jmp    800278 <transmode+0x81>
    if (S_ISDIR(mode)) return 'd';
  80021b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80021e:	25 00 70 00 00       	and    $0x7000,%eax
  800223:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800228:	75 07                	jne    800231 <transmode+0x3a>
  80022a:	b8 64 00 00 00       	mov    $0x64,%eax
  80022f:	eb 47                	jmp    800278 <transmode+0x81>
    if (S_ISLNK(mode)) return 'l';
  800231:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800234:	25 00 70 00 00       	and    $0x7000,%eax
  800239:	3d 00 30 00 00       	cmp    $0x3000,%eax
  80023e:	75 07                	jne    800247 <transmode+0x50>
  800240:	b8 6c 00 00 00       	mov    $0x6c,%eax
  800245:	eb 31                	jmp    800278 <transmode+0x81>
    if (S_ISCHR(mode)) return 'c';
  800247:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80024a:	25 00 70 00 00       	and    $0x7000,%eax
  80024f:	3d 00 40 00 00       	cmp    $0x4000,%eax
  800254:	75 07                	jne    80025d <transmode+0x66>
  800256:	b8 63 00 00 00       	mov    $0x63,%eax
  80025b:	eb 1b                	jmp    800278 <transmode+0x81>
    if (S_ISBLK(mode)) return 'b';
  80025d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800260:	25 00 70 00 00       	and    $0x7000,%eax
  800265:	3d 00 50 00 00       	cmp    $0x5000,%eax
  80026a:	75 07                	jne    800273 <transmode+0x7c>
  80026c:	b8 62 00 00 00       	mov    $0x62,%eax
  800271:	eb 05                	jmp    800278 <transmode+0x81>
    return '-';
  800273:	b8 2d 00 00 00       	mov    $0x2d,%eax
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <print_stat>:

void
print_stat(const char *name, int fd, struct stat *stat) {
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 18             	sub    $0x18,%esp
    cprintf("[%03d] %s\n", fd, name);
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 44 24 08          	mov    %eax,0x8(%esp)
  800287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	c7 04 24 10 20 80 00 	movl   $0x802010,(%esp)
  800295:	e8 6b 01 00 00       	call   800405 <cprintf>
    cprintf("    mode    : %c\n", transmode(stat));
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	e8 52 ff ff ff       	call   8001f7 <transmode>
  8002a5:	0f be c0             	movsbl %al,%eax
  8002a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ac:	c7 04 24 1b 20 80 00 	movl   $0x80201b,(%esp)
  8002b3:	e8 4d 01 00 00       	call   800405 <cprintf>
    cprintf("    links   : %lu\n", stat->st_nlinks);
  8002b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bb:	8b 40 04             	mov    0x4(%eax),%eax
  8002be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c2:	c7 04 24 2d 20 80 00 	movl   $0x80202d,(%esp)
  8002c9:	e8 37 01 00 00       	call   800405 <cprintf>
    cprintf("    blocks  : %lu\n", stat->st_blocks);
  8002ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d1:	8b 40 08             	mov    0x8(%eax),%eax
  8002d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d8:	c7 04 24 40 20 80 00 	movl   $0x802040,(%esp)
  8002df:	e8 21 01 00 00       	call   800405 <cprintf>
    cprintf("    size    : %lu\n", stat->st_size);
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8002ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ee:	c7 04 24 53 20 80 00 	movl   $0x802053,(%esp)
  8002f5:	e8 0b 01 00 00       	call   800405 <cprintf>
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002fc:	bd 00 00 00 00       	mov    $0x0,%ebp

    # load argc and argv
    movl (%esp), %ebx
  800301:	8b 1c 24             	mov    (%esp),%ebx
    lea 0x4(%esp), %ecx
  800304:	8d 4c 24 04          	lea    0x4(%esp),%ecx


    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800308:	83 ec 20             	sub    $0x20,%esp

    # save argc and argv on stack
    pushl %ecx
  80030b:	51                   	push   %ecx
    pushl %ebx
  80030c:	53                   	push   %ebx

    # call user-program function
    call umain
  80030d:	e8 26 07 00 00       	call   800a38 <umain>
1:  jmp 1b
  800312:	eb fe                	jmp    800312 <_start+0x16>

00800314 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80031a:	8d 45 14             	lea    0x14(%ebp),%eax
  80031d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 66 20 80 00 	movl   $0x802066,(%esp)
  800335:	e8 cb 00 00 00       	call   800405 <cprintf>
    vcprintf(fmt, ap);
  80033a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 7e 00 00 00       	call   8003ca <vcprintf>
    cprintf("\n");
  80034c:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  800353:	e8 ad 00 00 00       	call   800405 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800358:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80035f:	e8 64 05 00 00       	call   8008c8 <exit>

00800364 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  80036a:	8d 45 14             	lea    0x14(%ebp),%eax
  80036d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 08          	mov    %eax,0x8(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037e:	c7 04 24 82 20 80 00 	movl   $0x802082,(%esp)
  800385:	e8 7b 00 00 00       	call   800405 <cprintf>
    vcprintf(fmt, ap);
  80038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	8b 45 10             	mov    0x10(%ebp),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	e8 2e 00 00 00       	call   8003ca <vcprintf>
    cprintf("\n");
  80039c:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  8003a3:	e8 5d 00 00 00       	call   800405 <cprintf>
    va_end(ap);
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 45 02 00 00       	call   800600 <sys_putc>
    (*cnt) ++;
  8003bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	8d 50 01             	lea    0x1(%eax),%edx
  8003c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c6:	89 10                	mov    %edx,(%eax)
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  8003d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, NO_FD, &cnt, fmt, ap);
  8003d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ec:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  8003f3:	ff 
  8003f4:	c7 04 24 aa 03 80 00 	movl   $0x8003aa,(%esp)
  8003fb:	e8 f8 08 00 00       	call   800cf8 <vprintfmt>
    return cnt;
  800400:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  80040b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80040e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  800411:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800414:	89 44 24 04          	mov    %eax,0x4(%esp)
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	e8 a7 ff ff ff       	call   8003ca <vcprintf>
  800423:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800426:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800431:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800438:	eb 13                	jmp    80044d <cputs+0x22>
        cputch(c, &cnt);
  80043a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80043e:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800441:	89 54 24 04          	mov    %edx,0x4(%esp)
  800445:	89 04 24             	mov    %eax,(%esp)
  800448:	e8 5d ff ff ff       	call   8003aa <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	8d 50 01             	lea    0x1(%eax),%edx
  800453:	89 55 08             	mov    %edx,0x8(%ebp)
  800456:	0f b6 00             	movzbl (%eax),%eax
  800459:	88 45 f7             	mov    %al,-0x9(%ebp)
  80045c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800460:	75 d8                	jne    80043a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  800462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800465:	89 44 24 04          	mov    %eax,0x4(%esp)
  800469:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800470:	e8 35 ff ff ff       	call   8003aa <cputch>
    return cnt;
  800475:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fputch>:


static void
fputch(char c, int *cnt, int fd) {
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 18             	sub    $0x18,%esp
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	88 45 f4             	mov    %al,-0xc(%ebp)
    write(fd, &c, sizeof(char));
  800486:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80048d:	00 
  80048e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8b 45 10             	mov    0x10(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 ce fc ff ff       	call   80016e <write>
    (*cnt) ++;
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	8d 50 01             	lea    0x1(%eax),%edx
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	89 10                	mov    %edx,(%eax)
}
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap) {
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  8004b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)fputch, fd, &cnt, fmt, ap);
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d8:	c7 04 24 7a 04 80 00 	movl   $0x80047a,(%esp)
  8004df:	e8 14 08 00 00       	call   800cf8 <vprintfmt>
    return cnt;
  8004e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    

008004e9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...) {
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8004ef:	8d 45 10             	lea    0x10(%ebp),%eax
  8004f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vfprintf(fd, fmt, ap);
  8004f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	e8 a1 ff ff ff       	call   8004af <vfprintf>
  80050e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800511:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <syscall>:


#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  80051f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800522:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  800525:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80052c:	eb 16                	jmp    800544 <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  80052e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800537:	8b 10                	mov    (%eax),%edx
  800539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80053c:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  800540:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  800544:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  800548:	7e e4                	jle    80052e <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  80054a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  80054d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  800550:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  800553:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  800556:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	cd 80                	int    $0x80
  80055e:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  800561:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800564:	83 c4 20             	add    $0x20,%esp
  800567:	5b                   	pop    %ebx
  800568:	5e                   	pop    %esi
  800569:	5f                   	pop    %edi
  80056a:	5d                   	pop    %ebp
  80056b:	c3                   	ret    

0080056c <sys_exit>:

int
sys_exit(int error_code) {
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  800572:	8b 45 08             	mov    0x8(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800580:	e8 91 ff ff ff       	call   800516 <syscall>
}
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <sys_fork>:

int
sys_fork(void) {
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  80058d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800594:	e8 7d ff ff ff       	call   800516 <syscall>
}
  800599:	c9                   	leave  
  80059a:	c3                   	ret    

0080059b <sys_wait>:

int
sys_wait(int pid, int *store) {
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  8005a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8005b6:	e8 5b ff ff ff       	call   800516 <syscall>
}
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <sys_yield>:

int
sys_yield(void) {
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  8005c3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8005ca:	e8 47 ff ff ff       	call   800516 <syscall>
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <sys_kill>:

int
sys_kill(int pid) {
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005de:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8005e5:	e8 2c ff ff ff       	call   800516 <syscall>
}
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <sys_getpid>:

int
sys_getpid(void) {
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  8005f2:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  8005f9:	e8 18 ff ff ff       	call   800516 <syscall>
}
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <sys_putc>:

int
sys_putc(int c) {
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  800614:	e8 fd fe ff ff       	call   800516 <syscall>
}
  800619:	c9                   	leave  
  80061a:	c3                   	ret    

0080061b <sys_pgdir>:

int
sys_pgdir(void) {
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  800621:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  800628:	e8 e9 fe ff ff       	call   800516 <syscall>
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  800643:	e8 ce fe ff ff       	call   800516 <syscall>
}
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <sys_sleep>:

int
sys_sleep(unsigned int time) {
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_sleep, time);
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	89 44 24 04          	mov    %eax,0x4(%esp)
  800657:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80065e:	e8 b3 fe ff ff       	call   800516 <syscall>
}
  800663:	c9                   	leave  
  800664:	c3                   	ret    

00800665 <sys_gettime>:

size_t
sys_gettime(void) {
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  80066b:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  800672:	e8 9f fe ff ff       	call   800516 <syscall>
}
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <sys_exec>:

int
sys_exec(const char *name, int argc, const char **argv) {
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_exec, name, argc, argv);
  80067f:	8b 45 10             	mov    0x10(%ebp),%eax
  800682:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80069b:	e8 76 fe ff ff       	call   800516 <syscall>
}
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    

008006a2 <sys_open>:

int
sys_open(const char *path, uint32_t open_flags) {
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_open, path, open_flags);
  8006a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  8006bd:	e8 54 fe ff ff       	call   800516 <syscall>
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <sys_close>:

int
sys_close(int fd) {
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_close, fd);
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d1:	c7 04 24 65 00 00 00 	movl   $0x65,(%esp)
  8006d8:	e8 39 fe ff ff       	call   800516 <syscall>
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <sys_read>:

int
sys_read(int fd, void *base, size_t len) {
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_read, fd, base, len);
  8006e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fa:	c7 04 24 66 00 00 00 	movl   $0x66,(%esp)
  800701:	e8 10 fe ff ff       	call   800516 <syscall>
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <sys_write>:

int
sys_write(int fd, void *base, size_t len) {
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_write, fd, base, len);
  80070e:	8b 45 10             	mov    0x10(%ebp),%eax
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	8b 45 0c             	mov    0xc(%ebp),%eax
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	c7 04 24 67 00 00 00 	movl   $0x67,(%esp)
  80072a:	e8 e7 fd ff ff       	call   800516 <syscall>
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <sys_seek>:

int
sys_seek(int fd, off_t pos, int whence) {
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_seek, fd, pos, whence);
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800741:	89 44 24 08          	mov    %eax,0x8(%esp)
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
  800753:	e8 be fd ff ff       	call   800516 <syscall>
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <sys_fstat>:

int
sys_fstat(int fd, struct stat *stat) {
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_fstat, fd, stat);
  800760:	8b 45 0c             	mov    0xc(%ebp),%eax
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076e:	c7 04 24 6e 00 00 00 	movl   $0x6e,(%esp)
  800775:	e8 9c fd ff ff       	call   800516 <syscall>
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <sys_fsync>:

int
sys_fsync(int fd) {
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_fsync, fd);
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	89 44 24 04          	mov    %eax,0x4(%esp)
  800789:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
  800790:	e8 81 fd ff ff       	call   800516 <syscall>
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <sys_getcwd>:

int
sys_getcwd(char *buffer, size_t len) {
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getcwd, buffer, len);
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	c7 04 24 79 00 00 00 	movl   $0x79,(%esp)
  8007b2:	e8 5f fd ff ff       	call   800516 <syscall>
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <sys_getdirentry>:

int
sys_getdirentry(int fd, struct dirent *dirent) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getdirentry, fd, dirent);
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	c7 04 24 80 00 00 00 	movl   $0x80,(%esp)
  8007d4:	e8 3d fd ff ff       	call   800516 <syscall>
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <sys_dup>:

int
sys_dup(int fd1, int fd2) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_dup, fd1, fd2);
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ef:	c7 04 24 82 00 00 00 	movl   $0x82,(%esp)
  8007f6:	e8 1b fd ff ff       	call   800516 <syscall>
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <try_lock>:
lock_init(lock_t *l) {
    *l = 0;
}

static inline bool
try_lock(lock_t *l) {
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 10             	sub    $0x10,%esp
  800803:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  800810:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800813:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800816:	0f ab 02             	bts    %eax,(%edx)
  800819:	19 c0                	sbb    %eax,%eax
  80081b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  80081e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800822:	0f 95 c0             	setne  %al
  800825:	0f b6 c0             	movzbl %al,%eax
    return test_and_set_bit(0, l);
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <lock>:

static inline void
lock(lock_t *l) {
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 28             	sub    $0x28,%esp
    if (try_lock(l)) {
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c2 ff ff ff       	call   8007fd <try_lock>
  80083b:	85 c0                	test   %eax,%eax
  80083d:	74 38                	je     800877 <lock+0x4d>
        int step = 0;
  80083f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        do {
            yield();
  800846:	e8 df 00 00 00       	call   80092a <yield>
            if (++ step == 100) {
  80084b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80084f:	83 7d f4 64          	cmpl   $0x64,-0xc(%ebp)
  800853:	75 13                	jne    800868 <lock+0x3e>
                step = 0;
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
                sleep(10);
  80085c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800863:	e8 0f 01 00 00       	call   800977 <sleep>
            }
        } while (try_lock(l));
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 8a ff ff ff       	call   8007fd <try_lock>
  800873:	85 c0                	test   %eax,%eax
  800875:	75 cf                	jne    800846 <lock+0x1c>
    }
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <unlock>:

static inline void
unlock(lock_t *l) {
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 10             	sub    $0x10,%esp
  80087f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  80088c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80088f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800892:	0f b3 02             	btr    %eax,(%edx)
  800895:	19 c0                	sbb    %eax,%eax
  800897:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  80089a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    test_and_clear_bit(0, l);
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <lock_fork>:
#include <lock.h>

static lock_t fork_lock = INIT_LOCK;

void
lock_fork(void) {
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
    lock(&fork_lock);
  8008a6:	c7 04 24 38 30 80 00 	movl   $0x803038,(%esp)
  8008ad:	e8 78 ff ff ff       	call   80082a <lock>
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <unlock_fork>:

void
unlock_fork(void) {
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	83 ec 04             	sub    $0x4,%esp
    unlock(&fork_lock);
  8008ba:	c7 04 24 38 30 80 00 	movl   $0x803038,(%esp)
  8008c1:	e8 b3 ff ff ff       	call   800879 <unlock>
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <exit>:

void
exit(int error_code) {
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	e8 93 fc ff ff       	call   80056c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8008d9:	c7 04 24 9e 20 80 00 	movl   $0x80209e,(%esp)
  8008e0:	e8 20 fb ff ff       	call   800405 <cprintf>
    while (1);
  8008e5:	eb fe                	jmp    8008e5 <exit+0x1d>

008008e7 <fork>:
}

int
fork(void) {
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8008ed:	e8 95 fc ff ff       	call   800587 <sys_fork>
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <wait>:

int
wait(void) {
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  8008fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800901:	00 
  800902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800909:	e8 8d fc ff ff       	call   80059b <sys_wait>
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <waitpid>:

int
waitpid(int pid, int *store) {
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	89 04 24             	mov    %eax,(%esp)
  800923:	e8 73 fc ff ff       	call   80059b <sys_wait>
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <yield>:

void
yield(void) {
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800930:	e8 88 fc ff ff       	call   8005bd <sys_yield>
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <kill>:

int
kill(int pid) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	e8 89 fc ff ff       	call   8005d1 <sys_kill>
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <getpid>:

int
getpid(void) {
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800950:	e8 97 fc ff ff       	call   8005ec <sys_getpid>
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  80095d:	e8 b9 fc ff ff       	call   80061b <sys_pgdir>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	e8 ba fc ff ff       	call   80062f <sys_lab6_set_priority>
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <sleep>:

int
sleep(unsigned int time) {
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 18             	sub    $0x18,%esp
    return sys_sleep(time);
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	e8 c2 fc ff ff       	call   80064a <sys_sleep>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <gettime_msec>:

unsigned int
gettime_msec(void) {
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  800990:	e8 d0 fc ff ff       	call   800665 <sys_gettime>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <__exec>:

int
__exec(const char *name, const char **argv) {
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  80099d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (argv[argc] != NULL) {
  8009a4:	eb 04                	jmp    8009aa <__exec+0x13>
        argc ++;
  8009a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
}

int
__exec(const char *name, const char **argv) {
    int argc = 0;
    while (argv[argc] != NULL) {
  8009aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	01 d0                	add    %edx,%eax
  8009b9:	8b 00                	mov    (%eax),%eax
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	75 e7                	jne    8009a6 <__exec+0xf>
        argc ++;
    }
    return sys_exec(name, argc, argv);
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	89 04 24             	mov    %eax,(%esp)
  8009d3:	e8 a1 fc ff ff       	call   800679 <sys_exec>
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <initfd>:
#include <stat.h>

int main(int argc, char *argv[]);

static int
initfd(int fd2, const char *path, uint32_t open_flags) {
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 28             	sub    $0x28,%esp
    int fd1, ret;
    if ((fd1 = open(path, open_flags)) < 0) {
  8009e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	e8 06 f7 ff ff       	call   8000f8 <open>
  8009f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009f9:	79 05                	jns    800a00 <initfd+0x26>
        return fd1;
  8009fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fe:	eb 36                	jmp    800a36 <initfd+0x5c>
    }
    if (fd1 != fd2) {
  800a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a03:	3b 45 08             	cmp    0x8(%ebp),%eax
  800a06:	74 2b                	je     800a33 <initfd+0x59>
        close(fd2);
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 27 f7 ff ff       	call   80013a <close>
        ret = dup2(fd1, fd2);
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1d:	89 04 24             	mov    %eax,(%esp)
  800a20:	e8 b8 f7 ff ff       	call   8001dd <dup2>
  800a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  800a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2b:	89 04 24             	mov    %eax,(%esp)
  800a2e:	e8 07 f7 ff ff       	call   80013a <close>
    }
    return ret;
  800a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <umain>:

void
umain(int argc, char *argv[]) {
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 28             	sub    $0x28,%esp
    int fd;
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
  800a3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a45:	00 
  800a46:	c7 44 24 04 b1 20 80 	movl   $0x8020b1,0x4(%esp)
  800a4d:	00 
  800a4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a55:	e8 80 ff ff ff       	call   8009da <initfd>
  800a5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a61:	79 23                	jns    800a86 <umain+0x4e>
        warn("open <stdin> failed: %e.\n", fd);
  800a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6a:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800a71:	00 
  800a72:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800a79:	00 
  800a7a:	c7 04 24 d2 20 80 00 	movl   $0x8020d2,(%esp)
  800a81:	e8 de f8 ff ff       	call   800364 <__warn>
    }
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
  800a86:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800a8d:	00 
  800a8e:	c7 44 24 04 e4 20 80 	movl   $0x8020e4,0x4(%esp)
  800a95:	00 
  800a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9d:	e8 38 ff ff ff       	call   8009da <initfd>
  800aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800aa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800aa9:	79 23                	jns    800ace <umain+0x96>
        warn("open <stdout> failed: %e.\n", fd);
  800aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab2:	c7 44 24 08 ec 20 80 	movl   $0x8020ec,0x8(%esp)
  800ab9:	00 
  800aba:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800ac1:	00 
  800ac2:	c7 04 24 d2 20 80 00 	movl   $0x8020d2,(%esp)
  800ac9:	e8 96 f8 ff ff       	call   800364 <__warn>
    }
    int ret = main(argc, argv);
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	e8 95 13 00 00       	call   801e75 <main>
  800ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    exit(ret);
  800ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	e8 da fd ff ff       	call   8008c8 <exit>

00800aee <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800afd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800b00:	b8 20 00 00 00       	mov    $0x20,%eax
  800b05:	2b 45 0c             	sub    0xc(%ebp),%eax
  800b08:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b0b:	89 c1                	mov    %eax,%ecx
  800b0d:	d3 ea                	shr    %cl,%edx
  800b0f:	89 d0                	mov    %edx,%eax
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*, int), int fd, void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 58             	sub    $0x58,%esp
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b1f:	8b 45 18             	mov    0x18(%ebp),%eax
  800b22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800b25:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800b31:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b3a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b40:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b4d:	74 1c                	je     800b6b <printnum+0x58>
  800b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	f7 75 e4             	divl   -0x1c(%ebp)
  800b5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	f7 75 e4             	divl   -0x1c(%ebp)
  800b68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b71:	f7 75 e4             	divl   -0x1c(%ebp)
  800b74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b77:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b86:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b89:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800b8c:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800b97:	77 64                	ja     800bfd <printnum+0xea>
  800b99:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800b9c:	72 05                	jb     800ba3 <printnum+0x90>
  800b9e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  800ba1:	77 5a                	ja     800bfd <printnum+0xea>
        printnum(putch, fd, putdat, result, base, width - 1, padc);
  800ba3:	8b 45 20             	mov    0x20(%ebp),%eax
  800ba6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba9:	8b 45 24             	mov    0x24(%ebp),%eax
  800bac:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800bb0:	89 54 24 18          	mov    %edx,0x18(%esp)
  800bb4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800bb7:	89 44 24 14          	mov    %eax,0x14(%esp)
  800bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bbe:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800bc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	89 04 24             	mov    %eax,(%esp)
  800bdd:	e8 31 ff ff ff       	call   800b13 <printnum>
  800be2:	eb 23                	jmp    800c07 <printnum+0xf4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat, fd);
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800beb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf2:	8b 45 24             	mov    0x24(%ebp),%eax
  800bf5:	89 04 24             	mov    %eax,(%esp)
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, fd, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800bfd:	83 6d 20 01          	subl   $0x1,0x20(%ebp)
  800c01:	83 7d 20 00          	cmpl   $0x0,0x20(%ebp)
  800c05:	7f dd                	jg     800be4 <printnum+0xd1>
            putch(padc, putdat, fd);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat, fd);
  800c07:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c0a:	05 24 23 80 00       	add    $0x802324,%eax
  800c0f:	0f b6 00             	movzbl (%eax),%eax
  800c12:	0f be c0             	movsbl %al,%eax
  800c15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c18:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c1c:	8b 55 10             	mov    0x10(%ebp),%edx
  800c1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c23:	89 04 24             	mov    %eax,(%esp)
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	ff d0                	call   *%eax
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c30:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c34:	7e 14                	jle    800c4a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	8b 00                	mov    (%eax),%eax
  800c3b:	8d 48 08             	lea    0x8(%eax),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 0a                	mov    %ecx,(%edx)
  800c43:	8b 50 04             	mov    0x4(%eax),%edx
  800c46:	8b 00                	mov    (%eax),%eax
  800c48:	eb 30                	jmp    800c7a <getuint+0x4d>
    }
    else if (lflag) {
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 16                	je     800c66 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	8b 00                	mov    (%eax),%eax
  800c55:	8d 48 04             	lea    0x4(%eax),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 0a                	mov    %ecx,(%edx)
  800c5d:	8b 00                	mov    (%eax),%eax
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	eb 14                	jmp    800c7a <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	8b 00                	mov    (%eax),%eax
  800c6b:	8d 48 04             	lea    0x4(%eax),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 0a                	mov    %ecx,(%edx)
  800c73:	8b 00                	mov    (%eax),%eax
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c7f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c83:	7e 14                	jle    800c99 <getint+0x1d>
        return va_arg(*ap, long long);
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	8b 00                	mov    (%eax),%eax
  800c8a:	8d 48 08             	lea    0x8(%eax),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 0a                	mov    %ecx,(%edx)
  800c92:	8b 50 04             	mov    0x4(%eax),%edx
  800c95:	8b 00                	mov    (%eax),%eax
  800c97:	eb 28                	jmp    800cc1 <getint+0x45>
    }
    else if (lflag) {
  800c99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9d:	74 12                	je     800cb1 <getint+0x35>
        return va_arg(*ap, long);
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	8b 00                	mov    (%eax),%eax
  800ca4:	8d 48 04             	lea    0x4(%eax),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 0a                	mov    %ecx,(%edx)
  800cac:	8b 00                	mov    (%eax),%eax
  800cae:	99                   	cltd   
  800caf:	eb 10                	jmp    800cc1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	8b 00                	mov    (%eax),%eax
  800cb6:	8d 48 04             	lea    0x4(%eax),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 0a                	mov    %ecx,(%edx)
  800cbe:	8b 00                	mov    (%eax),%eax
  800cc0:	99                   	cltd   
    }
}
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <printfmt>:
 * @fd:         file descriptor
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, ...) {
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 38             	sub    $0x38,%esp
    va_list ap;

    va_start(ap, fmt);
  800cc9:	8d 45 18             	lea    0x18(%ebp),%eax
  800ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, fd, putdat, fmt, ap);
  800ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	89 04 24             	mov    %eax,(%esp)
  800cf1:	e8 02 00 00 00       	call   800cf8 <vprintfmt>
    va_end(ap);
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, va_list ap) {
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800d00:	eb 1f                	jmp    800d21 <vprintfmt+0x29>
            if (ch == '\0') {
  800d02:	85 db                	test   %ebx,%ebx
  800d04:	75 05                	jne    800d0b <vprintfmt+0x13>
                return;
  800d06:	e9 33 04 00 00       	jmp    80113e <vprintfmt+0x446>
            }
            putch(ch, putdat, fd);
  800d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d12:	8b 45 10             	mov    0x10(%ebp),%eax
  800d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d19:	89 1c 24             	mov    %ebx,(%esp)
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800d21:	8b 45 14             	mov    0x14(%ebp),%eax
  800d24:	8d 50 01             	lea    0x1(%eax),%edx
  800d27:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	0f b6 d8             	movzbl %al,%ebx
  800d30:	83 fb 25             	cmp    $0x25,%ebx
  800d33:	75 cd                	jne    800d02 <vprintfmt+0xa>
            }
            putch(ch, putdat, fd);
        }

        // Process a %-escape sequence
        char padc = ' ';
  800d35:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800d39:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d43:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800d46:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d50:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800d53:	8b 45 14             	mov    0x14(%ebp),%eax
  800d56:	8d 50 01             	lea    0x1(%eax),%edx
  800d59:	89 55 14             	mov    %edx,0x14(%ebp)
  800d5c:	0f b6 00             	movzbl (%eax),%eax
  800d5f:	0f b6 d8             	movzbl %al,%ebx
  800d62:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800d65:	83 f8 55             	cmp    $0x55,%eax
  800d68:	0f 87 98 03 00 00    	ja     801106 <vprintfmt+0x40e>
  800d6e:	8b 04 85 48 23 80 00 	mov    0x802348(,%eax,4),%eax
  800d75:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800d77:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800d7b:	eb d6                	jmp    800d53 <vprintfmt+0x5b>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800d7d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800d81:	eb d0                	jmp    800d53 <vprintfmt+0x5b>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800d83:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800d8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d8d:	89 d0                	mov    %edx,%eax
  800d8f:	c1 e0 02             	shl    $0x2,%eax
  800d92:	01 d0                	add    %edx,%eax
  800d94:	01 c0                	add    %eax,%eax
  800d96:	01 d8                	add    %ebx,%eax
  800d98:	83 e8 30             	sub    $0x30,%eax
  800d9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800d9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800da1:	0f b6 00             	movzbl (%eax),%eax
  800da4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800da7:	83 fb 2f             	cmp    $0x2f,%ebx
  800daa:	7e 0b                	jle    800db7 <vprintfmt+0xbf>
  800dac:	83 fb 39             	cmp    $0x39,%ebx
  800daf:	7f 06                	jg     800db7 <vprintfmt+0xbf>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800db1:	83 45 14 01          	addl   $0x1,0x14(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  800db5:	eb d3                	jmp    800d8a <vprintfmt+0x92>
            goto process_precision;
  800db7:	eb 33                	jmp    800dec <vprintfmt+0xf4>

        case '*':
            precision = va_arg(ap, int);
  800db9:	8b 45 18             	mov    0x18(%ebp),%eax
  800dbc:	8d 50 04             	lea    0x4(%eax),%edx
  800dbf:	89 55 18             	mov    %edx,0x18(%ebp)
  800dc2:	8b 00                	mov    (%eax),%eax
  800dc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800dc7:	eb 23                	jmp    800dec <vprintfmt+0xf4>

        case '.':
            if (width < 0)
  800dc9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800dcd:	79 0c                	jns    800ddb <vprintfmt+0xe3>
                width = 0;
  800dcf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800dd6:	e9 78 ff ff ff       	jmp    800d53 <vprintfmt+0x5b>
  800ddb:	e9 73 ff ff ff       	jmp    800d53 <vprintfmt+0x5b>

        case '#':
            altflag = 1;
  800de0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800de7:	e9 67 ff ff ff       	jmp    800d53 <vprintfmt+0x5b>

        process_precision:
            if (width < 0)
  800dec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800df0:	79 12                	jns    800e04 <vprintfmt+0x10c>
                width = precision, precision = -1;
  800df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800df8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800dff:	e9 4f ff ff ff       	jmp    800d53 <vprintfmt+0x5b>
  800e04:	e9 4a ff ff ff       	jmp    800d53 <vprintfmt+0x5b>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800e09:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800e0d:	e9 41 ff ff ff       	jmp    800d53 <vprintfmt+0x5b>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat, fd);
  800e12:	8b 45 18             	mov    0x18(%ebp),%eax
  800e15:	8d 50 04             	lea    0x4(%eax),%edx
  800e18:	89 55 18             	mov    %edx,0x18(%ebp)
  800e1b:	8b 00                	mov    (%eax),%eax
  800e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e20:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e24:	8b 55 10             	mov    0x10(%ebp),%edx
  800e27:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	ff d0                	call   *%eax
            break;
  800e33:	e9 00 03 00 00       	jmp    801138 <vprintfmt+0x440>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800e38:	8b 45 18             	mov    0x18(%ebp),%eax
  800e3b:	8d 50 04             	lea    0x4(%eax),%edx
  800e3e:	89 55 18             	mov    %edx,0x18(%ebp)
  800e41:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800e43:	85 db                	test   %ebx,%ebx
  800e45:	79 02                	jns    800e49 <vprintfmt+0x151>
                err = -err;
  800e47:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800e49:	83 fb 18             	cmp    $0x18,%ebx
  800e4c:	7f 0b                	jg     800e59 <vprintfmt+0x161>
  800e4e:	8b 34 9d c0 22 80 00 	mov    0x8022c0(,%ebx,4),%esi
  800e55:	85 f6                	test   %esi,%esi
  800e57:	75 2a                	jne    800e83 <vprintfmt+0x18b>
                printfmt(putch, fd, putdat, "error %d", err);
  800e59:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e5d:	c7 44 24 0c 35 23 80 	movl   $0x802335,0xc(%esp)
  800e64:	00 
  800e65:	8b 45 10             	mov    0x10(%ebp),%eax
  800e68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	89 04 24             	mov    %eax,(%esp)
  800e79:	e8 45 fe ff ff       	call   800cc3 <printfmt>
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
            }
            break;
  800e7e:	e9 b5 02 00 00       	jmp    801138 <vprintfmt+0x440>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, fd, putdat, "error %d", err);
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
  800e83:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e87:	c7 44 24 0c 3e 23 80 	movl   $0x80233e,0xc(%esp)
  800e8e:	00 
  800e8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	89 04 24             	mov    %eax,(%esp)
  800ea3:	e8 1b fe ff ff       	call   800cc3 <printfmt>
            }
            break;
  800ea8:	e9 8b 02 00 00       	jmp    801138 <vprintfmt+0x440>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800ead:	8b 45 18             	mov    0x18(%ebp),%eax
  800eb0:	8d 50 04             	lea    0x4(%eax),%edx
  800eb3:	89 55 18             	mov    %edx,0x18(%ebp)
  800eb6:	8b 30                	mov    (%eax),%esi
  800eb8:	85 f6                	test   %esi,%esi
  800eba:	75 05                	jne    800ec1 <vprintfmt+0x1c9>
                p = "(null)";
  800ebc:	be 41 23 80 00       	mov    $0x802341,%esi
            }
            if (width > 0 && padc != '-') {
  800ec1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800ec5:	7e 45                	jle    800f0c <vprintfmt+0x214>
  800ec7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800ecb:	74 3f                	je     800f0c <vprintfmt+0x214>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800ecd:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed7:	89 34 24             	mov    %esi,(%esp)
  800eda:	e8 3b 04 00 00       	call   80131a <strnlen>
  800edf:	29 c3                	sub    %eax,%ebx
  800ee1:	89 d8                	mov    %ebx,%eax
  800ee3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ee6:	eb 1e                	jmp    800f06 <vprintfmt+0x20e>
                    putch(padc, putdat, fd);
  800ee8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eef:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ef3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ef6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800efa:	89 04 24             	mov    %eax,(%esp)
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  800f02:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f06:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f0a:	7f dc                	jg     800ee8 <vprintfmt+0x1f0>
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800f0c:	eb 46                	jmp    800f54 <vprintfmt+0x25c>
                if (altflag && (ch < ' ' || ch > '~')) {
  800f0e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f12:	74 26                	je     800f3a <vprintfmt+0x242>
  800f14:	83 fb 1f             	cmp    $0x1f,%ebx
  800f17:	7e 05                	jle    800f1e <vprintfmt+0x226>
  800f19:	83 fb 7e             	cmp    $0x7e,%ebx
  800f1c:	7e 1c                	jle    800f3a <vprintfmt+0x242>
                    putch('?', putdat, fd);
  800f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f25:	8b 45 10             	mov    0x10(%ebp),%eax
  800f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
  800f36:	ff d0                	call   *%eax
  800f38:	eb 16                	jmp    800f50 <vprintfmt+0x258>
                }
                else {
                    putch(ch, putdat, fd);
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	8b 45 10             	mov    0x10(%ebp),%eax
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	89 1c 24             	mov    %ebx,(%esp)
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800f50:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f54:	89 f0                	mov    %esi,%eax
  800f56:	8d 70 01             	lea    0x1(%eax),%esi
  800f59:	0f b6 00             	movzbl (%eax),%eax
  800f5c:	0f be d8             	movsbl %al,%ebx
  800f5f:	85 db                	test   %ebx,%ebx
  800f61:	74 10                	je     800f73 <vprintfmt+0x27b>
  800f63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f67:	78 a5                	js     800f0e <vprintfmt+0x216>
  800f69:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800f6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f71:	79 9b                	jns    800f0e <vprintfmt+0x216>
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f73:	eb 1e                	jmp    800f93 <vprintfmt+0x29b>
                putch(' ', putdat, fd);
  800f75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f8f:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f97:	7f dc                	jg     800f75 <vprintfmt+0x27d>
                putch(' ', putdat, fd);
            }
            break;
  800f99:	e9 9a 01 00 00       	jmp    801138 <vprintfmt+0x440>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800f9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa5:	8d 45 18             	lea    0x18(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 cc fc ff ff       	call   800c7c <getint>
  800fb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fb3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fbc:	85 d2                	test   %edx,%edx
  800fbe:	79 2d                	jns    800fed <vprintfmt+0x2f5>
                putch('-', putdat, fd);
  800fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fce:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	ff d0                	call   *%eax
                num = -(long long)num;
  800fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fe0:	f7 d8                	neg    %eax
  800fe2:	83 d2 00             	adc    $0x0,%edx
  800fe5:	f7 da                	neg    %edx
  800fe7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fea:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800fed:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800ff4:	e9 b6 00 00 00       	jmp    8010af <vprintfmt+0x3b7>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800ff9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801000:	8d 45 18             	lea    0x18(%ebp),%eax
  801003:	89 04 24             	mov    %eax,(%esp)
  801006:	e8 22 fc ff ff       	call   800c2d <getuint>
  80100b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80100e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  801011:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  801018:	e9 92 00 00 00       	jmp    8010af <vprintfmt+0x3b7>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  80101d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801020:	89 44 24 04          	mov    %eax,0x4(%esp)
  801024:	8d 45 18             	lea    0x18(%ebp),%eax
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	e8 fe fb ff ff       	call   800c2d <getuint>
  80102f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801032:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  801035:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  80103c:	eb 71                	jmp    8010af <vprintfmt+0x3b7>

        // pointer
        case 'p':
            putch('0', putdat, fd);
  80103e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801041:	89 44 24 08          	mov    %eax,0x8(%esp)
  801045:	8b 45 10             	mov    0x10(%ebp),%eax
  801048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	ff d0                	call   *%eax
            putch('x', putdat, fd);
  801058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105f:	8b 45 10             	mov    0x10(%ebp),%eax
  801062:	89 44 24 04          	mov    %eax,0x4(%esp)
  801066:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  801072:	8b 45 18             	mov    0x18(%ebp),%eax
  801075:	8d 50 04             	lea    0x4(%eax),%edx
  801078:	89 55 18             	mov    %edx,0x18(%ebp)
  80107b:	8b 00                	mov    (%eax),%eax
  80107d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801080:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  801087:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  80108e:	eb 1f                	jmp    8010af <vprintfmt+0x3b7>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  801090:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801093:	89 44 24 04          	mov    %eax,0x4(%esp)
  801097:	8d 45 18             	lea    0x18(%ebp),%eax
  80109a:	89 04 24             	mov    %eax,(%esp)
  80109d:	e8 8b fb ff ff       	call   800c2d <getuint>
  8010a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  8010a8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, fd, putdat, num, base, width, padc);
  8010af:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8010b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010b6:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  8010ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8010bd:	89 54 24 18          	mov    %edx,0x18(%esp)
  8010c1:	89 44 24 14          	mov    %eax,0x14(%esp)
  8010c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010cf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	89 04 24             	mov    %eax,(%esp)
  8010e7:	e8 27 fa ff ff       	call   800b13 <printnum>
            break;
  8010ec:	eb 4a                	jmp    801138 <vprintfmt+0x440>

        // escaped '%' character
        case '%':
            putch(ch, putdat, fd);
  8010ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fc:	89 1c 24             	mov    %ebx,(%esp)
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	ff d0                	call   *%eax
            break;
  801104:	eb 32                	jmp    801138 <vprintfmt+0x440>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat, fd);
  801106:	8b 45 0c             	mov    0xc(%ebp),%eax
  801109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110d:	8b 45 10             	mov    0x10(%ebp),%eax
  801110:	89 44 24 04          	mov    %eax,0x4(%esp)
  801114:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  801120:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801124:	eb 04                	jmp    80112a <vprintfmt+0x432>
  801126:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  80112a:	8b 45 14             	mov    0x14(%ebp),%eax
  80112d:	83 e8 01             	sub    $0x1,%eax
  801130:	0f b6 00             	movzbl (%eax),%eax
  801133:	3c 25                	cmp    $0x25,%al
  801135:	75 ef                	jne    801126 <vprintfmt+0x42e>
                /* do nothing */;
            break;
  801137:	90                   	nop
        }
    }
  801138:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  801139:	e9 e3 fb ff ff       	jmp    800d21 <vprintfmt+0x29>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80113e:	83 c4 40             	add    $0x40,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  801148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114b:	8b 40 08             	mov    0x8(%eax),%eax
  80114e:	8d 50 01             	lea    0x1(%eax),%edx
  801151:	8b 45 0c             	mov    0xc(%ebp),%eax
  801154:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  801157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115a:	8b 10                	mov    (%eax),%edx
  80115c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115f:	8b 40 04             	mov    0x4(%eax),%eax
  801162:	39 c2                	cmp    %eax,%edx
  801164:	73 12                	jae    801178 <sprintputch+0x33>
        *b->buf ++ = ch;
  801166:	8b 45 0c             	mov    0xc(%ebp),%eax
  801169:	8b 00                	mov    (%eax),%eax
  80116b:	8d 48 01             	lea    0x1(%eax),%ecx
  80116e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801171:	89 0a                	mov    %ecx,(%edx)
  801173:	8b 55 08             	mov    0x8(%ebp),%edx
  801176:	88 10                	mov    %dl,(%eax)
    }
}
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  801180:	8d 45 14             	lea    0x14(%ebp),%eax
  801183:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  801186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118d:	8b 45 10             	mov    0x10(%ebp),%eax
  801190:	89 44 24 08          	mov    %eax,0x8(%esp)
  801194:	8b 45 0c             	mov    0xc(%ebp),%eax
  801197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	89 04 24             	mov    %eax,(%esp)
  8011a1:	e8 08 00 00 00       	call   8011ae <vsnprintf>
  8011a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  8011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 38             	sub    $0x38,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bd:	8d 50 ff             	lea    -0x1(%eax),%edx
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	01 d0                	add    %edx,%eax
  8011c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8011c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  8011cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011d3:	74 0a                	je     8011df <vsnprintf+0x31>
  8011d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011db:	39 c2                	cmp    %eax,%edx
  8011dd:	76 07                	jbe    8011e6 <vsnprintf+0x38>
        return -E_INVAL;
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb 32                	jmp    801218 <vsnprintf+0x6a>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, NO_FD, &b, fmt, ap);
  8011e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8011e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8011f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fb:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  801202:	ff 
  801203:	c7 04 24 45 11 80 00 	movl   $0x801145,(%esp)
  80120a:	e8 e9 fa ff ff       	call   800cf8 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80120f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801212:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  801215:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  801223:	a1 08 30 80 00       	mov    0x803008,%eax
  801228:	8b 15 0c 30 80 00    	mov    0x80300c,%edx
  80122e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  801234:	6b f0 05             	imul   $0x5,%eax,%esi
  801237:	01 f7                	add    %esi,%edi
  801239:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  80123e:	f7 e6                	mul    %esi
  801240:	8d 34 17             	lea    (%edi,%edx,1),%esi
  801243:	89 f2                	mov    %esi,%edx
  801245:	83 c0 0b             	add    $0xb,%eax
  801248:	83 d2 00             	adc    $0x0,%edx
  80124b:	89 c7                	mov    %eax,%edi
  80124d:	83 e7 ff             	and    $0xffffffff,%edi
  801250:	89 f9                	mov    %edi,%ecx
  801252:	0f b7 da             	movzwl %dx,%ebx
  801255:	89 0d 08 30 80 00    	mov    %ecx,0x803008
  80125b:	89 1d 0c 30 80 00    	mov    %ebx,0x80300c
    unsigned long long result = (next >> 12);
  801261:	a1 08 30 80 00       	mov    0x803008,%eax
  801266:	8b 15 0c 30 80 00    	mov    0x80300c,%edx
  80126c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  801270:	c1 ea 0c             	shr    $0xc,%edx
  801273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801276:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  801279:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  801280:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801283:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801286:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801289:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80128c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80128f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801292:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801296:	74 1c                	je     8012b4 <rand+0x9a>
  801298:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80129b:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a0:	f7 75 dc             	divl   -0x24(%ebp)
  8012a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ae:	f7 75 dc             	divl   -0x24(%ebp)
  8012b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8012ba:	f7 75 dc             	divl   -0x24(%ebp)
  8012bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012c6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012d2:	83 c4 24             	add    $0x24,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
    next = seed;
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	a3 08 30 80 00       	mov    %eax,0x803008
  8012ea:	89 15 0c 30 80 00    	mov    %edx,0x80300c
}
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8012f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8012ff:	eb 04                	jmp    801305 <strlen+0x13>
        cnt ++;
  801301:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	8d 50 01             	lea    0x1(%eax),%edx
  80130b:	89 55 08             	mov    %edx,0x8(%ebp)
  80130e:	0f b6 00             	movzbl (%eax),%eax
  801311:	84 c0                	test   %al,%al
  801313:	75 ec                	jne    801301 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  801315:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  801320:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  801327:	eb 04                	jmp    80132d <strnlen+0x13>
        cnt ++;
  801329:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80132d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801330:	3b 45 0c             	cmp    0xc(%ebp),%eax
  801333:	73 10                	jae    801345 <strnlen+0x2b>
  801335:	8b 45 08             	mov    0x8(%ebp),%eax
  801338:	8d 50 01             	lea    0x1(%eax),%edx
  80133b:	89 55 08             	mov    %edx,0x8(%ebp)
  80133e:	0f b6 00             	movzbl (%eax),%eax
  801341:	84 c0                	test   %al,%al
  801343:	75 e4                	jne    801329 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  801345:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <strcat>:
 * @dst:    pointer to the @dst array, which should be large enough to contain the concatenated
 *          resulting string.
 * @src:    string to be appended, this should not overlap @dst
 * */
char *
strcat(char *dst, const char *src) {
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 18             	sub    $0x18,%esp
    return strcpy(dst + strlen(dst), src);
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	89 04 24             	mov    %eax,(%esp)
  801356:	e8 97 ff ff ff       	call   8012f2 <strlen>
  80135b:	8b 55 08             	mov    0x8(%ebp),%edx
  80135e:	01 c2                	add    %eax,%edx
  801360:	8b 45 0c             	mov    0xc(%ebp),%eax
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	89 14 24             	mov    %edx,(%esp)
  80136a:	e8 02 00 00 00       	call   801371 <strcpy>
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	83 ec 20             	sub    $0x20,%esp
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80137f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801382:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  801385:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138b:	89 d1                	mov    %edx,%ecx
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	89 ce                	mov    %ecx,%esi
  801391:	89 d7                	mov    %edx,%edi
  801393:	ac                   	lods   %ds:(%esi),%al
  801394:	aa                   	stos   %al,%es:(%edi)
  801395:	84 c0                	test   %al,%al
  801397:	75 fa                	jne    801393 <strcpy+0x22>
  801399:	89 fa                	mov    %edi,%edx
  80139b:	89 f1                	mov    %esi,%ecx
  80139d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8013a0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8013a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  8013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  8013a9:	83 c4 20             	add    $0x20,%esp
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  8013b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  8013bc:	eb 21                	jmp    8013df <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  8013be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c1:	0f b6 10             	movzbl (%eax),%edx
  8013c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013c7:	88 10                	mov    %dl,(%eax)
  8013c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013cc:	0f b6 00             	movzbl (%eax),%eax
  8013cf:	84 c0                	test   %al,%al
  8013d1:	74 04                	je     8013d7 <strncpy+0x27>
            src ++;
  8013d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  8013d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8013db:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  8013df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e3:	75 d9                	jne    8013be <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	57                   	push   %edi
  8013ee:	56                   	push   %esi
  8013ef:	83 ec 20             	sub    $0x20,%esp
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  8013fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801401:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801404:	89 d1                	mov    %edx,%ecx
  801406:	89 c2                	mov    %eax,%edx
  801408:	89 ce                	mov    %ecx,%esi
  80140a:	89 d7                	mov    %edx,%edi
  80140c:	ac                   	lods   %ds:(%esi),%al
  80140d:	ae                   	scas   %es:(%edi),%al
  80140e:	75 08                	jne    801418 <strcmp+0x2e>
  801410:	84 c0                	test   %al,%al
  801412:	75 f8                	jne    80140c <strcmp+0x22>
  801414:	31 c0                	xor    %eax,%eax
  801416:	eb 04                	jmp    80141c <strcmp+0x32>
  801418:	19 c0                	sbb    %eax,%eax
  80141a:	0c 01                	or     $0x1,%al
  80141c:	89 fa                	mov    %edi,%edx
  80141e:	89 f1                	mov    %esi,%ecx
  801420:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801423:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  801426:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  801429:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  80142c:	83 c4 20             	add    $0x20,%esp
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  801436:	eb 0c                	jmp    801444 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  801438:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80143c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801440:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  801444:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801448:	74 1a                	je     801464 <strncmp+0x31>
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	0f b6 00             	movzbl (%eax),%eax
  801450:	84 c0                	test   %al,%al
  801452:	74 10                	je     801464 <strncmp+0x31>
  801454:	8b 45 08             	mov    0x8(%ebp),%eax
  801457:	0f b6 10             	movzbl (%eax),%edx
  80145a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145d:	0f b6 00             	movzbl (%eax),%eax
  801460:	38 c2                	cmp    %al,%dl
  801462:	74 d4                	je     801438 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  801464:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801468:	74 18                	je     801482 <strncmp+0x4f>
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	0f b6 00             	movzbl (%eax),%eax
  801470:	0f b6 d0             	movzbl %al,%edx
  801473:	8b 45 0c             	mov    0xc(%ebp),%eax
  801476:	0f b6 00             	movzbl (%eax),%eax
  801479:	0f b6 c0             	movzbl %al,%eax
  80147c:	29 c2                	sub    %eax,%edx
  80147e:	89 d0                	mov    %edx,%eax
  801480:	eb 05                	jmp    801487 <strncmp+0x54>
  801482:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801492:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  801495:	eb 14                	jmp    8014ab <strchr+0x22>
        if (*s == c) {
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	0f b6 00             	movzbl (%eax),%eax
  80149d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8014a0:	75 05                	jne    8014a7 <strchr+0x1e>
            return (char *)s;
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	eb 13                	jmp    8014ba <strchr+0x31>
        }
        s ++;
  8014a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	0f b6 00             	movzbl (%eax),%eax
  8014b1:	84 c0                	test   %al,%al
  8014b3:	75 e2                	jne    801497 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8014c8:	eb 11                	jmp    8014db <strfind+0x1f>
        if (*s == c) {
  8014ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cd:	0f b6 00             	movzbl (%eax),%eax
  8014d0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8014d3:	75 02                	jne    8014d7 <strfind+0x1b>
            break;
  8014d5:	eb 0e                	jmp    8014e5 <strfind+0x29>
        }
        s ++;
  8014d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	0f b6 00             	movzbl (%eax),%eax
  8014e1:	84 c0                	test   %al,%al
  8014e3:	75 e5                	jne    8014ca <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  8014f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  8014f7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  8014fe:	eb 04                	jmp    801504 <strtol+0x1a>
        s ++;
  801500:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	0f b6 00             	movzbl (%eax),%eax
  80150a:	3c 20                	cmp    $0x20,%al
  80150c:	74 f2                	je     801500 <strtol+0x16>
  80150e:	8b 45 08             	mov    0x8(%ebp),%eax
  801511:	0f b6 00             	movzbl (%eax),%eax
  801514:	3c 09                	cmp    $0x9,%al
  801516:	74 e8                	je     801500 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  801518:	8b 45 08             	mov    0x8(%ebp),%eax
  80151b:	0f b6 00             	movzbl (%eax),%eax
  80151e:	3c 2b                	cmp    $0x2b,%al
  801520:	75 06                	jne    801528 <strtol+0x3e>
        s ++;
  801522:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801526:	eb 15                	jmp    80153d <strtol+0x53>
    }
    else if (*s == '-') {
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	0f b6 00             	movzbl (%eax),%eax
  80152e:	3c 2d                	cmp    $0x2d,%al
  801530:	75 0b                	jne    80153d <strtol+0x53>
        s ++, neg = 1;
  801532:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801536:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  80153d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801541:	74 06                	je     801549 <strtol+0x5f>
  801543:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801547:	75 24                	jne    80156d <strtol+0x83>
  801549:	8b 45 08             	mov    0x8(%ebp),%eax
  80154c:	0f b6 00             	movzbl (%eax),%eax
  80154f:	3c 30                	cmp    $0x30,%al
  801551:	75 1a                	jne    80156d <strtol+0x83>
  801553:	8b 45 08             	mov    0x8(%ebp),%eax
  801556:	83 c0 01             	add    $0x1,%eax
  801559:	0f b6 00             	movzbl (%eax),%eax
  80155c:	3c 78                	cmp    $0x78,%al
  80155e:	75 0d                	jne    80156d <strtol+0x83>
        s += 2, base = 16;
  801560:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801564:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80156b:	eb 2a                	jmp    801597 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  80156d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801571:	75 17                	jne    80158a <strtol+0xa0>
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	0f b6 00             	movzbl (%eax),%eax
  801579:	3c 30                	cmp    $0x30,%al
  80157b:	75 0d                	jne    80158a <strtol+0xa0>
        s ++, base = 8;
  80157d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801581:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801588:	eb 0d                	jmp    801597 <strtol+0xad>
    }
    else if (base == 0) {
  80158a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80158e:	75 07                	jne    801597 <strtol+0xad>
        base = 10;
  801590:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  801597:	8b 45 08             	mov    0x8(%ebp),%eax
  80159a:	0f b6 00             	movzbl (%eax),%eax
  80159d:	3c 2f                	cmp    $0x2f,%al
  80159f:	7e 1b                	jle    8015bc <strtol+0xd2>
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a4:	0f b6 00             	movzbl (%eax),%eax
  8015a7:	3c 39                	cmp    $0x39,%al
  8015a9:	7f 11                	jg     8015bc <strtol+0xd2>
            dig = *s - '0';
  8015ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ae:	0f b6 00             	movzbl (%eax),%eax
  8015b1:	0f be c0             	movsbl %al,%eax
  8015b4:	83 e8 30             	sub    $0x30,%eax
  8015b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015ba:	eb 48                	jmp    801604 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  8015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bf:	0f b6 00             	movzbl (%eax),%eax
  8015c2:	3c 60                	cmp    $0x60,%al
  8015c4:	7e 1b                	jle    8015e1 <strtol+0xf7>
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	0f b6 00             	movzbl (%eax),%eax
  8015cc:	3c 7a                	cmp    $0x7a,%al
  8015ce:	7f 11                	jg     8015e1 <strtol+0xf7>
            dig = *s - 'a' + 10;
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	0f b6 00             	movzbl (%eax),%eax
  8015d6:	0f be c0             	movsbl %al,%eax
  8015d9:	83 e8 57             	sub    $0x57,%eax
  8015dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015df:	eb 23                	jmp    801604 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	0f b6 00             	movzbl (%eax),%eax
  8015e7:	3c 40                	cmp    $0x40,%al
  8015e9:	7e 3d                	jle    801628 <strtol+0x13e>
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	0f b6 00             	movzbl (%eax),%eax
  8015f1:	3c 5a                	cmp    $0x5a,%al
  8015f3:	7f 33                	jg     801628 <strtol+0x13e>
            dig = *s - 'A' + 10;
  8015f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f8:	0f b6 00             	movzbl (%eax),%eax
  8015fb:	0f be c0             	movsbl %al,%eax
  8015fe:	83 e8 37             	sub    $0x37,%eax
  801601:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  801604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801607:	3b 45 10             	cmp    0x10(%ebp),%eax
  80160a:	7c 02                	jl     80160e <strtol+0x124>
            break;
  80160c:	eb 1a                	jmp    801628 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  80160e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801612:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801615:	0f af 45 10          	imul   0x10(%ebp),%eax
  801619:	89 c2                	mov    %eax,%edx
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	01 d0                	add    %edx,%eax
  801620:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  801623:	e9 6f ff ff ff       	jmp    801597 <strtol+0xad>

    if (endptr) {
  801628:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80162c:	74 08                	je     801636 <strtol+0x14c>
        *endptr = (char *) s;
  80162e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801631:	8b 55 08             	mov    0x8(%ebp),%edx
  801634:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  801636:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80163a:	74 07                	je     801643 <strtol+0x159>
  80163c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80163f:	f7 d8                	neg    %eax
  801641:	eb 03                	jmp    801646 <strtol+0x15c>
  801643:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	83 ec 24             	sub    $0x24,%esp
  80164f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801652:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  801655:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
  80165c:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80165f:	88 45 f7             	mov    %al,-0x9(%ebp)
  801662:	8b 45 10             	mov    0x10(%ebp),%eax
  801665:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  801668:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80166b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80166f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801672:	89 d7                	mov    %edx,%edi
  801674:	f3 aa                	rep stos %al,%es:(%edi)
  801676:	89 fa                	mov    %edi,%edx
  801678:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80167b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  80167e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  801681:	83 c4 24             	add    $0x24,%esp
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 30             	sub    $0x30,%esp
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
  801699:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80169c:	8b 45 10             	mov    0x10(%ebp),%eax
  80169f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8016a8:	73 42                	jae    8016ec <memmove+0x65>
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8016bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016bf:	c1 e8 02             	shr    $0x2,%eax
  8016c2:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  8016c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ca:	89 d7                	mov    %edx,%edi
  8016cc:	89 c6                	mov    %eax,%esi
  8016ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016d3:	83 e1 03             	and    $0x3,%ecx
  8016d6:	74 02                	je     8016da <memmove+0x53>
  8016d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8016da:	89 f0                	mov    %esi,%eax
  8016dc:	89 fa                	mov    %edi,%edx
  8016de:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8016e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  8016e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ea:	eb 36                	jmp    801722 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  8016ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016ef:	8d 50 ff             	lea    -0x1(%eax),%edx
  8016f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016f5:	01 c2                	add    %eax,%edx
  8016f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016fa:	8d 48 ff             	lea    -0x1(%eax),%ecx
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  801703:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801706:	89 c1                	mov    %eax,%ecx
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	89 d6                	mov    %edx,%esi
  80170c:	89 c7                	mov    %eax,%edi
  80170e:	fd                   	std    
  80170f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  801711:	fc                   	cld    
  801712:	89 f8                	mov    %edi,%eax
  801714:	89 f2                	mov    %esi,%edx
  801716:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801719:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80171c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  80171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  801722:	83 c4 30             	add    $0x30,%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5f                   	pop    %edi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	57                   	push   %edi
  80172e:	56                   	push   %esi
  80172f:	83 ec 20             	sub    $0x20,%esp
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80173e:	8b 45 10             	mov    0x10(%ebp),%eax
  801741:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  801744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801747:	c1 e8 02             	shr    $0x2,%eax
  80174a:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  80174c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	89 d7                	mov    %edx,%edi
  801754:	89 c6                	mov    %eax,%esi
  801756:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801758:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80175b:	83 e1 03             	and    $0x3,%ecx
  80175e:	74 02                	je     801762 <memcpy+0x38>
  801760:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  801762:	89 f0                	mov    %esi,%eax
  801764:	89 fa                	mov    %edi,%edx
  801766:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  801769:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80176c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  801772:	83 c4 20             	add    $0x20,%esp
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  801785:	8b 45 0c             	mov    0xc(%ebp),%eax
  801788:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  80178b:	eb 30                	jmp    8017bd <memcmp+0x44>
        if (*s1 != *s2) {
  80178d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801790:	0f b6 10             	movzbl (%eax),%edx
  801793:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801796:	0f b6 00             	movzbl (%eax),%eax
  801799:	38 c2                	cmp    %al,%dl
  80179b:	74 18                	je     8017b5 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  80179d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017a0:	0f b6 00             	movzbl (%eax),%eax
  8017a3:	0f b6 d0             	movzbl %al,%edx
  8017a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8017a9:	0f b6 00             	movzbl (%eax),%eax
  8017ac:	0f b6 c0             	movzbl %al,%eax
  8017af:	29 c2                	sub    %eax,%edx
  8017b1:	89 d0                	mov    %edx,%eax
  8017b3:	eb 1a                	jmp    8017cf <memcmp+0x56>
        }
        s1 ++, s2 ++;
  8017b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8017b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  8017bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c0:	8d 50 ff             	lea    -0x1(%eax),%edx
  8017c3:	89 55 10             	mov    %edx,0x10(%ebp)
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	75 c3                	jne    80178d <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <gettoken>:
#define SYMBOLS                         "<|>&;"

char shcwd[BUFSIZE];

int
gettoken(char **p1, char **p2) {
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 28             	sub    $0x28,%esp
    char *s;
    if ((s = *p1) == NULL) {
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	8b 00                	mov    (%eax),%eax
  8017dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8017df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017e3:	75 0a                	jne    8017ef <gettoken+0x1e>
        return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ea:	e9 f8 00 00 00       	jmp    8018e7 <gettoken+0x116>
    }
    while (strchr(WHITESPACE, *s) != NULL) {
  8017ef:	eb 0c                	jmp    8017fd <gettoken+0x2c>
        *s ++ = '\0';
  8017f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f4:	8d 50 01             	lea    0x1(%eax),%edx
  8017f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8017fa:	c6 00 00             	movb   $0x0,(%eax)
gettoken(char **p1, char **p2) {
    char *s;
    if ((s = *p1) == NULL) {
        return 0;
    }
    while (strchr(WHITESPACE, *s) != NULL) {
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	0f b6 00             	movzbl (%eax),%eax
  801803:	0f be c0             	movsbl %al,%eax
  801806:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180a:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  801811:	e8 73 fc ff ff       	call   801489 <strchr>
  801816:	85 c0                	test   %eax,%eax
  801818:	75 d7                	jne    8017f1 <gettoken+0x20>
        *s ++ = '\0';
    }
    if (*s == '\0') {
  80181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181d:	0f b6 00             	movzbl (%eax),%eax
  801820:	84 c0                	test   %al,%al
  801822:	75 0a                	jne    80182e <gettoken+0x5d>
        return 0;
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
  801829:	e9 b9 00 00 00       	jmp    8018e7 <gettoken+0x116>
    }

    *p2 = s;
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801834:	89 10                	mov    %edx,(%eax)
    int token = 'w';
  801836:	c7 45 f0 77 00 00 00 	movl   $0x77,-0x10(%ebp)
    if (strchr(SYMBOLS, *s) != NULL) {
  80183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801840:	0f b6 00             	movzbl (%eax),%eax
  801843:	0f be c0             	movsbl %al,%eax
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	c7 04 24 a5 24 80 00 	movl   $0x8024a5,(%esp)
  801851:	e8 33 fc ff ff       	call   801489 <strchr>
  801856:	85 c0                	test   %eax,%eax
  801858:	74 1a                	je     801874 <gettoken+0xa3>
        token = *s, *s ++ = '\0';
  80185a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185d:	0f b6 00             	movzbl (%eax),%eax
  801860:	0f be c0             	movsbl %al,%eax
  801863:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	8d 50 01             	lea    0x1(%eax),%edx
  80186c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80186f:	c6 00 00             	movb   $0x0,(%eax)
  801872:	eb 57                	jmp    8018cb <gettoken+0xfa>
    }
    else {
        bool flag = 0;
  801874:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        while (*s != '\0' && (flag || strchr(WHITESPACE SYMBOLS, *s) == NULL)) {
  80187b:	eb 21                	jmp    80189e <gettoken+0xcd>
            if (*s == '"') {
  80187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801880:	0f b6 00             	movzbl (%eax),%eax
  801883:	3c 22                	cmp    $0x22,%al
  801885:	75 13                	jne    80189a <gettoken+0xc9>
                *s = ' ', flag = !flag;
  801887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188a:	c6 00 20             	movb   $0x20,(%eax)
  80188d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801891:	0f 94 c0             	sete   %al
  801894:	0f b6 c0             	movzbl %al,%eax
  801897:	89 45 ec             	mov    %eax,-0x14(%ebp)
            }
            s ++;
  80189a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if (strchr(SYMBOLS, *s) != NULL) {
        token = *s, *s ++ = '\0';
    }
    else {
        bool flag = 0;
        while (*s != '\0' && (flag || strchr(WHITESPACE SYMBOLS, *s) == NULL)) {
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	0f b6 00             	movzbl (%eax),%eax
  8018a4:	84 c0                	test   %al,%al
  8018a6:	74 23                	je     8018cb <gettoken+0xfa>
  8018a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8018ac:	75 cf                	jne    80187d <gettoken+0xac>
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	0f b6 00             	movzbl (%eax),%eax
  8018b4:	0f be c0             	movsbl %al,%eax
  8018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bb:	c7 04 24 ab 24 80 00 	movl   $0x8024ab,(%esp)
  8018c2:	e8 c2 fb ff ff       	call   801489 <strchr>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	74 b2                	je     80187d <gettoken+0xac>
                *s = ' ', flag = !flag;
            }
            s ++;
        }
    }
    *p1 = (*s != '\0' ? s : NULL);
  8018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ce:	0f b6 00             	movzbl (%eax),%eax
  8018d1:	84 c0                	test   %al,%al
  8018d3:	74 05                	je     8018da <gettoken+0x109>
  8018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d8:	eb 05                	jmp    8018df <gettoken+0x10e>
  8018da:	b8 00 00 00 00       	mov    $0x0,%eax
  8018df:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e2:	89 02                	mov    %eax,(%edx)
    return token;
  8018e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <readline>:

char *
readline(const char *prompt) {
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 28             	sub    $0x28,%esp
    static char buffer[BUFSIZE];
    if (prompt != NULL) {
  8018ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8018f3:	74 1b                	je     801910 <readline+0x27>
        printf("%s", prompt);
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fc:	c7 44 24 04 b5 24 80 	movl   $0x8024b5,0x4(%esp)
  801903:	00 
  801904:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80190b:	e8 d9 eb ff ff       	call   8004e9 <fprintf>
    }
    int ret, i = 0;
  801910:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
  801917:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80191e:	00 
  80191f:	8d 45 ef             	lea    -0x11(%ebp),%eax
  801922:	89 44 24 04          	mov    %eax,0x4(%esp)
  801926:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192d:	e8 1b e8 ff ff       	call   80014d <read>
  801932:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801935:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801939:	79 0a                	jns    801945 <readline+0x5c>
            return NULL;
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
  801940:	e9 f6 00 00 00       	jmp    801a3b <readline+0x152>
        }
        else if (ret == 0) {
  801945:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801949:	75 20                	jne    80196b <readline+0x82>
            if (i > 0) {
  80194b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80194f:	7e 10                	jle    801961 <readline+0x78>
                buffer[i] = '\0';
  801951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801954:	05 80 30 80 00       	add    $0x803080,%eax
  801959:	c6 00 00             	movb   $0x0,(%eax)
                break;
  80195c:	e9 d5 00 00 00       	jmp    801a36 <readline+0x14d>
            }
            return NULL;
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
  801966:	e9 d0 00 00 00       	jmp    801a3b <readline+0x152>
        }

        if (c == 3) {
  80196b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  80196f:	3c 03                	cmp    $0x3,%al
  801971:	75 0a                	jne    80197d <readline+0x94>
            return NULL;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	e9 be 00 00 00       	jmp    801a3b <readline+0x152>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  80197d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801981:	3c 1f                	cmp    $0x1f,%al
  801983:	7e 3d                	jle    8019c2 <readline+0xd9>
  801985:	81 7d f4 fe 0f 00 00 	cmpl   $0xffe,-0xc(%ebp)
  80198c:	7f 34                	jg     8019c2 <readline+0xd9>
            putc(c);
  80198e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801992:	0f be c0             	movsbl %al,%eax
  801995:	89 44 24 08          	mov    %eax,0x8(%esp)
  801999:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  8019a0:	00 
  8019a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019a8:	e8 3c eb ff ff       	call   8004e9 <fprintf>
            buffer[i ++] = c;
  8019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b0:	8d 50 01             	lea    0x1(%eax),%edx
  8019b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019b6:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
  8019ba:	88 90 80 30 80 00    	mov    %dl,0x803080(%eax)
  8019c0:	eb 6f                	jmp    801a31 <readline+0x148>
        }
        else if (c == '\b' && i > 0) {
  8019c2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8019c6:	3c 08                	cmp    $0x8,%al
  8019c8:	75 2b                	jne    8019f5 <readline+0x10c>
  8019ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8019ce:	7e 25                	jle    8019f5 <readline+0x10c>
            putc(c);
  8019d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8019d4:	0f be c0             	movsbl %al,%eax
  8019d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019db:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  8019e2:	00 
  8019e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ea:	e8 fa ea ff ff       	call   8004e9 <fprintf>
            i --;
  8019ef:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  8019f3:	eb 3c                	jmp    801a31 <readline+0x148>
        }
        else if (c == '\n' || c == '\r') {
  8019f5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8019f9:	3c 0a                	cmp    $0xa,%al
  8019fb:	74 08                	je     801a05 <readline+0x11c>
  8019fd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801a01:	3c 0d                	cmp    $0xd,%al
  801a03:	75 2c                	jne    801a31 <readline+0x148>
            putc(c);
  801a05:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801a09:	0f be c0             	movsbl %al,%eax
  801a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a10:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  801a17:	00 
  801a18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a1f:	e8 c5 ea ff ff       	call   8004e9 <fprintf>
            buffer[i] = '\0';
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	05 80 30 80 00       	add    $0x803080,%eax
  801a2c:	c6 00 00             	movb   $0x0,(%eax)
            break;
  801a2f:	eb 05                	jmp    801a36 <readline+0x14d>
        }
    }
  801a31:	e9 e1 fe ff ff       	jmp    801917 <readline+0x2e>
    return buffer;
  801a36:	b8 80 30 80 00       	mov    $0x803080,%eax
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <usage>:

void
usage(void) {
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 18             	sub    $0x18,%esp
    printf("usage: sh [command-file]\n");
  801a43:	c7 44 24 04 bb 24 80 	movl   $0x8024bb,0x4(%esp)
  801a4a:	00 
  801a4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a52:	e8 92 ea ff ff       	call   8004e9 <fprintf>
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <reopen>:

int
reopen(int fd2, const char *filename, uint32_t open_flags) {
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 28             	sub    $0x28,%esp
    int ret, fd1;
    close(fd2);
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	89 04 24             	mov    %eax,(%esp)
  801a65:	e8 d0 e6 ff ff       	call   80013a <close>
    if ((ret = open(filename, open_flags)) >= 0 && ret != fd2) {
  801a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 7c e6 ff ff       	call   8000f8 <open>
  801a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801a7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801a83:	78 39                	js     801abe <reopen+0x65>
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	3b 45 08             	cmp    0x8(%ebp),%eax
  801a8b:	74 31                	je     801abe <reopen+0x65>
        close(fd2);
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	89 04 24             	mov    %eax,(%esp)
  801a93:	e8 a2 e6 ff ff       	call   80013a <close>
        fd1 = ret, ret = dup2(fd1, fd2);
  801a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa8:	89 04 24             	mov    %eax,(%esp)
  801aab:	e8 2d e7 ff ff       	call   8001dd <dup2>
  801ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  801ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab6:	89 04 24             	mov    %eax,(%esp)
  801ab9:	e8 7c e6 ff ff       	call   80013a <close>
    }
    return ret < 0 ? ret : 0;
  801abe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801ac7:	0f 4e 45 f4          	cmovle -0xc(%ebp),%eax
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <testfile>:

int
testfile(const char *name) {
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 28             	sub    $0x28,%esp
    int ret;
    if ((ret = open(name, O_RDONLY)) < 0) {
  801ad3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ada:	00 
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	89 04 24             	mov    %eax,(%esp)
  801ae1:	e8 12 e6 ff ff       	call   8000f8 <open>
  801ae6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801ae9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801aed:	79 05                	jns    801af4 <testfile+0x27>
        return ret;
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	eb 10                	jmp    801b04 <testfile+0x37>
    }
    close(ret);
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	89 04 24             	mov    %eax,(%esp)
  801afa:	e8 3b e6 ff ff       	call   80013a <close>
    return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <runcmd>:

int
runcmd(char *cmd) {
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	81 ec b8 00 00 00    	sub    $0xb8,%esp
    static char argv0[BUFSIZE];
    const char *argv[EXEC_MAX_ARG_NUM + 1];
    char *t;
    int argc, token, ret, p[2];
again:
    argc = 0;
  801b0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        switch (token = gettoken(&cmd, &t)) {
  801b16:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  801b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b20:	8d 45 08             	lea    0x8(%ebp),%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 a6 fc ff ff       	call   8017d1 <gettoken>
  801b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b31:	83 f8 3c             	cmp    $0x3c,%eax
  801b34:	74 76                	je     801bac <runcmd+0xa6>
  801b36:	83 f8 3c             	cmp    $0x3c,%eax
  801b39:	7f 16                	jg     801b51 <runcmd+0x4b>
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	0f 84 62 02 00 00    	je     801da5 <runcmd+0x29f>
  801b43:	83 f8 3b             	cmp    $0x3b,%eax
  801b46:	0f 84 f9 01 00 00    	je     801d45 <runcmd+0x23f>
  801b4c:	e9 2a 02 00 00       	jmp    801d7b <runcmd+0x275>
  801b51:	83 f8 77             	cmp    $0x77,%eax
  801b54:	74 17                	je     801b6d <runcmd+0x67>
  801b56:	83 f8 7c             	cmp    $0x7c,%eax
  801b59:	0f 84 25 01 00 00    	je     801c84 <runcmd+0x17e>
  801b5f:	83 f8 3e             	cmp    $0x3e,%eax
  801b62:	0f 84 b0 00 00 00    	je     801c18 <runcmd+0x112>
  801b68:	e9 0e 02 00 00       	jmp    801d7b <runcmd+0x275>
        case 'w':
            if (argc == EXEC_MAX_ARG_NUM) {
  801b6d:	83 7d f4 20          	cmpl   $0x20,-0xc(%ebp)
  801b71:	75 1e                	jne    801b91 <runcmd+0x8b>
                printf("sh error: too many arguments\n");
  801b73:	c7 44 24 04 d5 24 80 	movl   $0x8024d5,0x4(%esp)
  801b7a:	00 
  801b7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b82:	e8 62 e9 ff ff       	call   8004e9 <fprintf>
                return -1;
  801b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b8c:	e9 e2 02 00 00       	jmp    801e73 <runcmd+0x36d>
            }
            argv[argc ++] = t;
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	8d 50 01             	lea    0x1(%eax),%edx
  801b97:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b9a:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
  801ba0:	89 94 85 68 ff ff ff 	mov    %edx,-0x98(%ebp,%eax,4)
            break;
  801ba7:	e9 f4 01 00 00       	jmp    801da0 <runcmd+0x29a>
        case '<':
            if (gettoken(&cmd, &t) != 'w') {
  801bac:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  801bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb6:	8d 45 08             	lea    0x8(%ebp),%eax
  801bb9:	89 04 24             	mov    %eax,(%esp)
  801bbc:	e8 10 fc ff ff       	call   8017d1 <gettoken>
  801bc1:	83 f8 77             	cmp    $0x77,%eax
  801bc4:	74 1e                	je     801be4 <runcmd+0xde>
                printf("sh error: syntax error: < not followed by word\n");
  801bc6:	c7 44 24 04 f4 24 80 	movl   $0x8024f4,0x4(%esp)
  801bcd:	00 
  801bce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801bd5:	e8 0f e9 ff ff       	call   8004e9 <fprintf>
                return -1;
  801bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bdf:	e9 8f 02 00 00       	jmp    801e73 <runcmd+0x36d>
            }
            if ((ret = reopen(0, t, O_RDONLY)) != 0) {
  801be4:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801bea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf1:	00 
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfd:	e8 57 fe ff ff       	call   801a59 <reopen>
  801c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801c09:	74 08                	je     801c13 <runcmd+0x10d>
                return ret;
  801c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c0e:	e9 60 02 00 00       	jmp    801e73 <runcmd+0x36d>
            }
            break;
  801c13:	e9 88 01 00 00       	jmp    801da0 <runcmd+0x29a>
        case '>':
            if (gettoken(&cmd, &t) != 'w') {
  801c18:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  801c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c22:	8d 45 08             	lea    0x8(%ebp),%eax
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 a4 fb ff ff       	call   8017d1 <gettoken>
  801c2d:	83 f8 77             	cmp    $0x77,%eax
  801c30:	74 1e                	je     801c50 <runcmd+0x14a>
                printf("sh error: syntax error: > not followed by word\n");
  801c32:	c7 44 24 04 24 25 80 	movl   $0x802524,0x4(%esp)
  801c39:	00 
  801c3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c41:	e8 a3 e8 ff ff       	call   8004e9 <fprintf>
                return -1;
  801c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c4b:	e9 23 02 00 00       	jmp    801e73 <runcmd+0x36d>
            }
            if ((ret = reopen(1, t, O_RDWR | O_TRUNC | O_CREAT)) != 0) {
  801c50:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801c56:	c7 44 24 08 16 00 00 	movl   $0x16,0x8(%esp)
  801c5d:	00 
  801c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c69:	e8 eb fd ff ff       	call   801a59 <reopen>
  801c6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c71:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801c75:	74 08                	je     801c7f <runcmd+0x179>
                return ret;
  801c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c7a:	e9 f4 01 00 00       	jmp    801e73 <runcmd+0x36d>
            }
            break;
  801c7f:	e9 1c 01 00 00       	jmp    801da0 <runcmd+0x29a>
        case '|':
          //  if ((ret = pipe(p)) != 0) {
          //      return ret;
          //  }
            if ((ret = fork()) == 0) {
  801c84:	e8 5e ec ff ff       	call   8008e7 <fork>
  801c89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c8c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801c90:	75 54                	jne    801ce6 <runcmd+0x1e0>
                close(0);
  801c92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c99:	e8 9c e4 ff ff       	call   80013a <close>
                if ((ret = dup2(p[0], 0)) < 0) {
  801c9e:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801ca4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cab:	00 
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 29 e5 ff ff       	call   8001dd <dup2>
  801cb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cb7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801cbb:	79 08                	jns    801cc5 <runcmd+0x1bf>
                    return ret;
  801cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cc0:	e9 ae 01 00 00       	jmp    801e73 <runcmd+0x36d>
                }
                close(p[0]), close(p[1]);
  801cc5:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 67 e4 ff ff       	call   80013a <close>
  801cd3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801cd9:	89 04 24             	mov    %eax,(%esp)
  801cdc:	e8 59 e4 ff ff       	call   80013a <close>
                goto again;
  801ce1:	e9 29 fe ff ff       	jmp    801b0f <runcmd+0x9>
            }
            else {
                if (ret < 0) {
  801ce6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801cea:	79 08                	jns    801cf4 <runcmd+0x1ee>
                    return ret;
  801cec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cef:	e9 7f 01 00 00       	jmp    801e73 <runcmd+0x36d>
                }
                close(1);
  801cf4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801cfb:	e8 3a e4 ff ff       	call   80013a <close>
                if ((ret = dup2(p[1], 1)) < 0) {
  801d00:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801d06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d0d:	00 
  801d0e:	89 04 24             	mov    %eax,(%esp)
  801d11:	e8 c7 e4 ff ff       	call   8001dd <dup2>
  801d16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801d1d:	79 08                	jns    801d27 <runcmd+0x221>
                    return ret;
  801d1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d22:	e9 4c 01 00 00       	jmp    801e73 <runcmd+0x36d>
                }
                close(p[0]), close(p[1]);
  801d27:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 05 e4 ff ff       	call   80013a <close>
  801d35:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801d3b:	89 04 24             	mov    %eax,(%esp)
  801d3e:	e8 f7 e3 ff ff       	call   80013a <close>
                goto runit;
  801d43:	eb 61                	jmp    801da6 <runcmd+0x2a0>
            }
            break;
        case 0:
            goto runit;
        case ';':
            if ((ret = fork()) == 0) {
  801d45:	e8 9d eb ff ff       	call   8008e7 <fork>
  801d4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d4d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801d51:	75 02                	jne    801d55 <runcmd+0x24f>
                goto runit;
  801d53:	eb 51                	jmp    801da6 <runcmd+0x2a0>
            }
            else {
                if (ret < 0) {
  801d55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801d59:	79 08                	jns    801d63 <runcmd+0x25d>
                    return ret;
  801d5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d5e:	e9 10 01 00 00       	jmp    801e73 <runcmd+0x36d>
                }
                waitpid(ret, NULL);
  801d63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d6a:	00 
  801d6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 9a eb ff ff       	call   800910 <waitpid>
                goto again;
  801d76:	e9 94 fd ff ff       	jmp    801b0f <runcmd+0x9>
            }
            break;
        default:
            printf("sh error: bad return %d from gettoken\n", token);
  801d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d82:	c7 44 24 04 54 25 80 	movl   $0x802554,0x4(%esp)
  801d89:	00 
  801d8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d91:	e8 53 e7 ff ff       	call   8004e9 <fprintf>
            return -1;
  801d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d9b:	e9 d3 00 00 00       	jmp    801e73 <runcmd+0x36d>
        }
    }
  801da0:	e9 71 fd ff ff       	jmp    801b16 <runcmd+0x10>
                close(p[0]), close(p[1]);
                goto runit;
            }
            break;
        case 0:
            goto runit;
  801da5:	90                   	nop
            return -1;
        }
    }

runit:
    if (argc == 0) {
  801da6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801daa:	75 0a                	jne    801db6 <runcmd+0x2b0>
        return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
  801db1:	e9 bd 00 00 00       	jmp    801e73 <runcmd+0x36d>
    }
    else if (strcmp(argv[0], "cd") == 0) {
  801db6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801dbc:	c7 44 24 04 7b 25 80 	movl   $0x80257b,0x4(%esp)
  801dc3:	00 
  801dc4:	89 04 24             	mov    %eax,(%esp)
  801dc7:	e8 1e f6 ff ff       	call   8013ea <strcmp>
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	75 2d                	jne    801dfd <runcmd+0x2f7>
        if (argc != 2) {
  801dd0:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  801dd4:	74 0a                	je     801de0 <runcmd+0x2da>
            return -1;
  801dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ddb:	e9 93 00 00 00       	jmp    801e73 <runcmd+0x36d>
        }
        strcpy(shcwd, argv[1]);
  801de0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  801de6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dea:	c7 04 24 a0 51 80 00 	movl   $0x8051a0,(%esp)
  801df1:	e8 7b f5 ff ff       	call   801371 <strcpy>
        return 0;
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	eb 76                	jmp    801e73 <runcmd+0x36d>
    }
    if ((ret = testfile(argv[0])) != 0) {
  801dfd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801e03:	89 04 24             	mov    %eax,(%esp)
  801e06:	e8 c2 fc ff ff       	call   801acd <testfile>
  801e0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e0e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801e12:	74 3b                	je     801e4f <runcmd+0x349>
        if (ret != -E_NOENT) {
  801e14:	83 7d ec f0          	cmpl   $0xfffffff0,-0x14(%ebp)
  801e18:	74 05                	je     801e1f <runcmd+0x319>
            return ret;
  801e1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e1d:	eb 54                	jmp    801e73 <runcmd+0x36d>
        }
        snprintf(argv0, sizeof(argv0), "/%s", argv[0]);
  801e1f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801e25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e29:	c7 44 24 08 7e 25 80 	movl   $0x80257e,0x8(%esp)
  801e30:	00 
  801e31:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801e38:	00 
  801e39:	c7 04 24 80 40 80 00 	movl   $0x804080,(%esp)
  801e40:	e8 35 f3 ff ff       	call   80117a <snprintf>
        argv[0] = argv0;
  801e45:	c7 85 68 ff ff ff 80 	movl   $0x804080,-0x98(%ebp)
  801e4c:	40 80 00 
    }
    argv[argc] = NULL;
  801e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e52:	c7 84 85 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%eax,4)
  801e59:	00 00 00 00 
    return __exec(NULL, argv);
  801e5d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6e:	e8 24 eb ff ff       	call   800997 <__exec>
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <main>:

int
main(int argc, char **argv) {
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 e4 f0             	and    $0xfffffff0,%esp
  801e7b:	83 ec 20             	sub    $0x20,%esp
    printf("user sh is running!!!");
  801e7e:	c7 44 24 04 82 25 80 	movl   $0x802582,0x4(%esp)
  801e85:	00 
  801e86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801e8d:	e8 57 e6 ff ff       	call   8004e9 <fprintf>
    int ret, interactive = 1;
  801e92:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  801e99:	00 
    if (argc == 2) {
  801e9a:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  801e9e:	75 3f                	jne    801edf <main+0x6a>
        if ((ret = reopen(0, argv[1], O_RDONLY)) != 0) {
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	83 c0 04             	add    $0x4,%eax
  801ea6:	8b 00                	mov    (%eax),%eax
  801ea8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eaf:	00 
  801eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebb:	e8 99 fb ff ff       	call   801a59 <reopen>
  801ec0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ec4:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	74 09                	je     801ed5 <main+0x60>
            return ret;
  801ecc:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ed0:	e9 10 01 00 00       	jmp    801fe5 <main+0x170>
        }
        interactive = 0;
  801ed5:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  801edc:	00 
  801edd:	eb 15                	jmp    801ef4 <main+0x7f>
    }
    else if (argc > 2) {
  801edf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  801ee3:	7e 0f                	jle    801ef4 <main+0x7f>
        usage();
  801ee5:	e8 53 fb ff ff       	call   801a3d <usage>
        return -1;
  801eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801eef:	e9 f1 00 00 00       	jmp    801fe5 <main+0x170>
    }
    //shcwd = malloc(BUFSIZE);
    assert(shcwd != NULL);

    char *buffer;
    while ((buffer = readline((interactive) ? "$ " : NULL)) != NULL) {
  801ef4:	e9 bd 00 00 00       	jmp    801fb6 <main+0x141>
        shcwd[0] = '\0';
  801ef9:	c6 05 a0 51 80 00 00 	movb   $0x0,0x8051a0
        int pid;
        if ((pid = fork()) == 0) {
  801f00:	e8 e2 e9 ff ff       	call   8008e7 <fork>
  801f05:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f09:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
  801f0e:	75 1c                	jne    801f2c <main+0xb7>
            ret = runcmd(buffer);
  801f10:	8b 44 24 18          	mov    0x18(%esp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 ea fb ff ff       	call   801b06 <runcmd>
  801f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
            exit(ret);
  801f20:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 9c e9 ff ff       	call   8008c8 <exit>
        }
        assert(pid >= 0);
  801f2c:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
  801f31:	79 24                	jns    801f57 <main+0xe2>
  801f33:	c7 44 24 0c 98 25 80 	movl   $0x802598,0xc(%esp)
  801f3a:	00 
  801f3b:	c7 44 24 08 a1 25 80 	movl   $0x8025a1,0x8(%esp)
  801f42:	00 
  801f43:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801f4a:	00 
  801f4b:	c7 04 24 b6 25 80 00 	movl   $0x8025b6,(%esp)
  801f52:	e8 bd e3 ff ff       	call   800314 <__panic>
        if (waitpid(pid, &ret) == 0) {
  801f57:	8d 44 24 10          	lea    0x10(%esp),%eax
  801f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f63:	89 04 24             	mov    %eax,(%esp)
  801f66:	e8 a5 e9 ff ff       	call   800910 <waitpid>
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	75 47                	jne    801fb6 <main+0x141>
            if (ret == 0 && shcwd[0] != '\0') {
  801f6f:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f73:	85 c0                	test   %eax,%eax
  801f75:	75 13                	jne    801f8a <main+0x115>
  801f77:	0f b6 05 a0 51 80 00 	movzbl 0x8051a0,%eax
  801f7e:	84 c0                	test   %al,%al
  801f80:	74 08                	je     801f8a <main+0x115>
                ret = 0;
  801f82:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801f89:	00 
            }
            if (ret != 0) {
  801f8a:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	74 24                	je     801fb6 <main+0x141>
                printf("error: %d - %e\n", ret, ret);
  801f92:	8b 54 24 10          	mov    0x10(%esp),%edx
  801f96:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa2:	c7 44 24 04 c0 25 80 	movl   $0x8025c0,0x4(%esp)
  801fa9:	00 
  801faa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801fb1:	e8 33 e5 ff ff       	call   8004e9 <fprintf>
    }
    //shcwd = malloc(BUFSIZE);
    assert(shcwd != NULL);

    char *buffer;
    while ((buffer = readline((interactive) ? "$ " : NULL)) != NULL) {
  801fb6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  801fbb:	74 07                	je     801fc4 <main+0x14f>
  801fbd:	b8 d0 25 80 00       	mov    $0x8025d0,%eax
  801fc2:	eb 05                	jmp    801fc9 <main+0x154>
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 18 f9 ff ff       	call   8018e9 <readline>
  801fd1:	89 44 24 18          	mov    %eax,0x18(%esp)
  801fd5:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  801fda:	0f 85 19 ff ff ff    	jne    801ef9 <main+0x84>
            if (ret != 0) {
                printf("error: %d - %e\n", ret, ret);
            }
        }
    }
    return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    
