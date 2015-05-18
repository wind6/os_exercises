
obj/__user_forktest.out:     file format elf32-i386


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
  800027:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
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
  800050:	a1 00 20 80 00       	mov    0x802000,%eax
  800055:	8b 00                	mov    (%eax),%eax
  800057:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80005a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 56 01 00 00       	call   8001bc <fstat>
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
  80007b:	a1 00 20 80 00       	mov    0x802000,%eax
  800080:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    return dirp;
  800087:	a1 00 20 80 00       	mov    0x802000,%eax
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
  8000b1:	e8 0f 07 00 00       	call   8007c5 <sys_getdirentry>
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
  8000d7:	e8 36 00 00 00       	call   800112 <close>
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
  8000f1:	e8 ad 06 00 00       	call   8007a3 <sys_getcwd>
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
    return sys_open(path, open_flags);
  8000fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800101:	89 44 24 04          	mov    %eax,0x4(%esp)
  800105:	8b 45 08             	mov    0x8(%ebp),%eax
  800108:	89 04 24             	mov    %eax,(%esp)
  80010b:	e8 9e 05 00 00       	call   8006ae <sys_open>
}
  800110:	c9                   	leave  
  800111:	c3                   	ret    

00800112 <close>:

int
close(int fd) {
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 18             	sub    $0x18,%esp
    return sys_close(fd);
  800118:	8b 45 08             	mov    0x8(%ebp),%eax
  80011b:	89 04 24             	mov    %eax,(%esp)
  80011e:	e8 ad 05 00 00       	call   8006d0 <sys_close>
}
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <read>:

int
read(int fd, void *base, size_t len) {
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp
    _filestep = 0;
  80012b:	c7 05 20 20 80 00 00 	movl   $0x0,0x802020
  800132:	00 00 00 
    cprintf("%d [user_read]\n", _filestep++);
  800135:	a1 20 20 80 00       	mov    0x802020,%eax
  80013a:	8d 50 01             	lea    0x1(%eax),%edx
  80013d:	89 15 20 20 80 00    	mov    %edx,0x802020
  800143:	89 44 24 04          	mov    %eax,0x4(%esp)
  800147:	c7 04 24 00 19 80 00 	movl   $0x801900,(%esp)
  80014e:	e8 be 02 00 00       	call   800411 <cprintf>
    return sys_read(fd, base, len);
  800153:	8b 45 10             	mov    0x10(%ebp),%eax
  800156:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 7f 05 00 00       	call   8006eb <sys_read>
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <write>:

int
write(int fd, void *base, size_t len) {
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 18             	sub    $0x18,%esp
    cprintf("[user_write]\n");
  800174:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  80017b:	e8 91 02 00 00       	call   800411 <cprintf>
    return sys_write(fd, base, len);
  800180:	8b 45 10             	mov    0x10(%ebp),%eax
  800183:	89 44 24 08          	mov    %eax,0x8(%esp)
  800187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 04 24             	mov    %eax,(%esp)
  800194:	e8 7b 05 00 00       	call   800714 <sys_write>
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <seek>:

int
seek(int fd, off_t pos, int whence) {
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
    return sys_seek(fd, pos, whence);
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	e8 83 05 00 00       	call   80073d <sys_seek>
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <fstat>:

int
fstat(int fd, struct stat *stat) {
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 18             	sub    $0x18,%esp
    return sys_fstat(fd, stat);
  8001c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 92 05 00 00       	call   800766 <sys_fstat>
}
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    

008001d6 <fsync>:

int
fsync(int fd) {
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 18             	sub    $0x18,%esp
    return sys_fsync(fd);
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 a1 05 00 00       	call   800788 <sys_fsync>
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <dup2>:

int
dup2(int fd1, int fd2) {
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 18             	sub    $0x18,%esp
    return sys_dup(fd1, fd2);
  8001ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 e6 05 00 00       	call   8007e7 <sys_dup>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <transmode>:

static char
transmode(struct stat *stat) {
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
    uint32_t mode = stat->st_mode;
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	8b 00                	mov    (%eax),%eax
  80020e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (S_ISREG(mode)) return 'r';
  800211:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800214:	25 00 70 00 00       	and    $0x7000,%eax
  800219:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80021e:	75 07                	jne    800227 <transmode+0x24>
  800220:	b8 72 00 00 00       	mov    $0x72,%eax
  800225:	eb 5d                	jmp    800284 <transmode+0x81>
    if (S_ISDIR(mode)) return 'd';
  800227:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80022a:	25 00 70 00 00       	and    $0x7000,%eax
  80022f:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800234:	75 07                	jne    80023d <transmode+0x3a>
  800236:	b8 64 00 00 00       	mov    $0x64,%eax
  80023b:	eb 47                	jmp    800284 <transmode+0x81>
    if (S_ISLNK(mode)) return 'l';
  80023d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800240:	25 00 70 00 00       	and    $0x7000,%eax
  800245:	3d 00 30 00 00       	cmp    $0x3000,%eax
  80024a:	75 07                	jne    800253 <transmode+0x50>
  80024c:	b8 6c 00 00 00       	mov    $0x6c,%eax
  800251:	eb 31                	jmp    800284 <transmode+0x81>
    if (S_ISCHR(mode)) return 'c';
  800253:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800256:	25 00 70 00 00       	and    $0x7000,%eax
  80025b:	3d 00 40 00 00       	cmp    $0x4000,%eax
  800260:	75 07                	jne    800269 <transmode+0x66>
  800262:	b8 63 00 00 00       	mov    $0x63,%eax
  800267:	eb 1b                	jmp    800284 <transmode+0x81>
    if (S_ISBLK(mode)) return 'b';
  800269:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80026c:	25 00 70 00 00       	and    $0x7000,%eax
  800271:	3d 00 50 00 00       	cmp    $0x5000,%eax
  800276:	75 07                	jne    80027f <transmode+0x7c>
  800278:	b8 62 00 00 00       	mov    $0x62,%eax
  80027d:	eb 05                	jmp    800284 <transmode+0x81>
    return '-';
  80027f:	b8 2d 00 00 00       	mov    $0x2d,%eax
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <print_stat>:

void
print_stat(const char *name, int fd, struct stat *stat) {
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 18             	sub    $0x18,%esp
    cprintf("[%03d] %s\n", fd, name);
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	c7 04 24 1e 19 80 00 	movl   $0x80191e,(%esp)
  8002a1:	e8 6b 01 00 00       	call   800411 <cprintf>
    cprintf("    mode    : %c\n", transmode(stat));
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	e8 52 ff ff ff       	call   800203 <transmode>
  8002b1:	0f be c0             	movsbl %al,%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 29 19 80 00 	movl   $0x801929,(%esp)
  8002bf:	e8 4d 01 00 00       	call   800411 <cprintf>
    cprintf("    links   : %lu\n", stat->st_nlinks);
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	8b 40 04             	mov    0x4(%eax),%eax
  8002ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ce:	c7 04 24 3b 19 80 00 	movl   $0x80193b,(%esp)
  8002d5:	e8 37 01 00 00       	call   800411 <cprintf>
    cprintf("    blocks  : %lu\n", stat->st_blocks);
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dd:	8b 40 08             	mov    0x8(%eax),%eax
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 4e 19 80 00 	movl   $0x80194e,(%esp)
  8002eb:	e8 21 01 00 00       	call   800411 <cprintf>
    cprintf("    size    : %lu\n", stat->st_size);
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800301:	e8 0b 01 00 00       	call   800411 <cprintf>
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  800308:	bd 00 00 00 00       	mov    $0x0,%ebp

    # load argc and argv
    movl (%esp), %ebx
  80030d:	8b 1c 24             	mov    (%esp),%ebx
    lea 0x4(%esp), %ecx
  800310:	8d 4c 24 04          	lea    0x4(%esp),%ecx


    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800314:	83 ec 20             	sub    $0x20,%esp

    # save argc and argv on stack
    pushl %ecx
  800317:	51                   	push   %ecx
    pushl %ebx
  800318:	53                   	push   %ebx

    # call user-program function
    call umain
  800319:	e8 26 07 00 00       	call   800a44 <umain>
1:  jmp 1b
  80031e:	eb fe                	jmp    80031e <_start+0x16>

00800320 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
  800329:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80032c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033a:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  800341:	e8 cb 00 00 00       	call   800411 <cprintf>
    vcprintf(fmt, ap);
  800346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	8b 45 10             	mov    0x10(%ebp),%eax
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	e8 7e 00 00 00       	call   8003d6 <vcprintf>
    cprintf("\n");
  800358:	c7 04 24 8e 19 80 00 	movl   $0x80198e,(%esp)
  80035f:	e8 ad 00 00 00       	call   800411 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800364:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80036b:	e8 64 05 00 00       	call   8008d4 <exit>

00800370 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800376:	8d 45 14             	lea    0x14(%ebp),%eax
  800379:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	c7 04 24 90 19 80 00 	movl   $0x801990,(%esp)
  800391:	e8 7b 00 00 00       	call   800411 <cprintf>
    vcprintf(fmt, ap);
  800396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 2e 00 00 00       	call   8003d6 <vcprintf>
    cprintf("\n");
  8003a8:	c7 04 24 8e 19 80 00 	movl   $0x80198e,(%esp)
  8003af:	e8 5d 00 00 00       	call   800411 <cprintf>
    va_end(ap);
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	e8 45 02 00 00       	call   80060c <sys_putc>
    (*cnt) ++;
  8003c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	8d 50 01             	lea    0x1(%eax),%edx
  8003cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d2:	89 10                	mov    %edx,(%eax)
}
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  8003dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, NO_FD, &cnt, fmt, ap);
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f8:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  8003ff:	ff 
  800400:	c7 04 24 b6 03 80 00 	movl   $0x8003b6,(%esp)
  800407:	e8 f8 08 00 00       	call   800d04 <vprintfmt>
    return cnt;
  80040c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800417:	8d 45 0c             	lea    0xc(%ebp),%eax
  80041a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  80041d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800420:	89 44 24 04          	mov    %eax,0x4(%esp)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 a7 ff ff ff       	call   8003d6 <vcprintf>
  80042f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800432:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  80043d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800444:	eb 13                	jmp    800459 <cputs+0x22>
        cputch(c, &cnt);
  800446:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80044a:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80044d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	e8 5d ff ff ff       	call   8003b6 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
  80045c:	8d 50 01             	lea    0x1(%eax),%edx
  80045f:	89 55 08             	mov    %edx,0x8(%ebp)
  800462:	0f b6 00             	movzbl (%eax),%eax
  800465:	88 45 f7             	mov    %al,-0x9(%ebp)
  800468:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  80046c:	75 d8                	jne    800446 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  80046e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800471:	89 44 24 04          	mov    %eax,0x4(%esp)
  800475:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80047c:	e8 35 ff ff ff       	call   8003b6 <cputch>
    return cnt;
  800481:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <fputch>:


static void
fputch(char c, int *cnt, int fd) {
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 18             	sub    $0x18,%esp
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	88 45 f4             	mov    %al,-0xc(%ebp)
    write(fd, &c, sizeof(char));
  800492:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800499:	00 
  80049a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 c2 fc ff ff       	call   80016e <write>
    (*cnt) ++;
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	8d 50 01             	lea    0x1(%eax),%edx
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 10                	mov    %edx,(%eax)
}
  8004b9:	c9                   	leave  
  8004ba:	c3                   	ret    

008004bb <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap) {
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
  8004be:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  8004c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)fputch, fd, &cnt, fmt, ap);
  8004c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e4:	c7 04 24 86 04 80 00 	movl   $0x800486,(%esp)
  8004eb:	e8 14 08 00 00       	call   800d04 <vprintfmt>
    return cnt;
  8004f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8004f3:	c9                   	leave  
  8004f4:	c3                   	ret    

008004f5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...) {
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8004fb:	8d 45 10             	lea    0x10(%ebp),%eax
  8004fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vfprintf(fd, fmt, ap);
  800501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800504:	89 44 24 08          	mov    %eax,0x8(%esp)
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	e8 a1 ff ff ff       	call   8004bb <vfprintf>
  80051a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  80051d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <syscall>:


#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  80052b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80052e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  800531:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800538:	eb 16                	jmp    800550 <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  80053a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800543:	8b 10                	mov    (%eax),%edx
  800545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800548:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  80054c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  800550:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  800554:	7e e4                	jle    80053a <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  800556:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  800559:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  80055c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  80055f:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  800562:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	cd 80                	int    $0x80
  80056a:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  80056d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800570:	83 c4 20             	add    $0x20,%esp
  800573:	5b                   	pop    %ebx
  800574:	5e                   	pop    %esi
  800575:	5f                   	pop    %edi
  800576:	5d                   	pop    %ebp
  800577:	c3                   	ret    

00800578 <sys_exit>:

int
sys_exit(int error_code) {
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80058c:	e8 91 ff ff ff       	call   800522 <syscall>
}
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <sys_fork>:

int
sys_fork(void) {
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  800599:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8005a0:	e8 7d ff ff ff       	call   800522 <syscall>
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <sys_wait>:

int
sys_wait(int pid, int *store) {
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  8005ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8005c2:	e8 5b ff ff ff       	call   800522 <syscall>
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <sys_yield>:

int
sys_yield(void) {
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  8005cf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8005d6:	e8 47 ff ff ff       	call   800522 <syscall>
}
  8005db:	c9                   	leave  
  8005dc:	c3                   	ret    

008005dd <sys_kill>:

int
sys_kill(int pid) {
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  8005e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ea:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8005f1:	e8 2c ff ff ff       	call   800522 <syscall>
}
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <sys_getpid>:

int
sys_getpid(void) {
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  8005fe:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800605:	e8 18 ff ff ff       	call   800522 <syscall>
}
  80060a:	c9                   	leave  
  80060b:	c3                   	ret    

0080060c <sys_putc>:

int
sys_putc(int c) {
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  800612:	8b 45 08             	mov    0x8(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  800620:	e8 fd fe ff ff       	call   800522 <syscall>
}
  800625:	c9                   	leave  
  800626:	c3                   	ret    

00800627 <sys_pgdir>:

int
sys_pgdir(void) {
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  80062d:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  800634:	e8 e9 fe ff ff       	call   800522 <syscall>
}
  800639:	c9                   	leave  
  80063a:	c3                   	ret    

0080063b <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	89 44 24 04          	mov    %eax,0x4(%esp)
  800648:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  80064f:	e8 ce fe ff ff       	call   800522 <syscall>
}
  800654:	c9                   	leave  
  800655:	c3                   	ret    

00800656 <sys_sleep>:

int
sys_sleep(unsigned int time) {
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_sleep, time);
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800663:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80066a:	e8 b3 fe ff ff       	call   800522 <syscall>
}
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <sys_gettime>:

size_t
sys_gettime(void) {
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  800677:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  80067e:	e8 9f fe ff ff       	call   800522 <syscall>
}
  800683:	c9                   	leave  
  800684:	c3                   	ret    

00800685 <sys_exec>:

int
sys_exec(const char *name, int argc, const char **argv) {
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_exec, name, argc, argv);
  80068b:	8b 45 10             	mov    0x10(%ebp),%eax
  80068e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800692:	8b 45 0c             	mov    0xc(%ebp),%eax
  800695:	89 44 24 08          	mov    %eax,0x8(%esp)
  800699:	8b 45 08             	mov    0x8(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8006a7:	e8 76 fe ff ff       	call   800522 <syscall>
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <sys_open>:

int
sys_open(const char *path, uint32_t open_flags) {
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_open, path, open_flags);
  8006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  8006c9:	e8 54 fe ff ff       	call   800522 <syscall>
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <sys_close>:

int
sys_close(int fd) {
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_close, fd);
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	c7 04 24 65 00 00 00 	movl   $0x65,(%esp)
  8006e4:	e8 39 fe ff ff       	call   800522 <syscall>
}
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <sys_read>:

int
sys_read(int fd, void *base, size_t len) {
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_read, fd, base, len);
  8006f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	c7 04 24 66 00 00 00 	movl   $0x66,(%esp)
  80070d:	e8 10 fe ff ff       	call   800522 <syscall>
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <sys_write>:

int
sys_write(int fd, void *base, size_t len) {
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_write, fd, base, len);
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	c7 04 24 67 00 00 00 	movl   $0x67,(%esp)
  800736:	e8 e7 fd ff ff       	call   800522 <syscall>
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <sys_seek>:

int
sys_seek(int fd, off_t pos, int whence) {
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_seek, fd, pos, whence);
  800743:	8b 45 10             	mov    0x10(%ebp),%eax
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
  80075f:	e8 be fd ff ff       	call   800522 <syscall>
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <sys_fstat>:

int
sys_fstat(int fd, struct stat *stat) {
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_fstat, fd, stat);
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077a:	c7 04 24 6e 00 00 00 	movl   $0x6e,(%esp)
  800781:	e8 9c fd ff ff       	call   800522 <syscall>
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <sys_fsync>:

int
sys_fsync(int fd) {
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_fsync, fd);
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
  80079c:	e8 81 fd ff ff       	call   800522 <syscall>
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <sys_getcwd>:

int
sys_getcwd(char *buffer, size_t len) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getcwd, buffer, len);
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	c7 04 24 79 00 00 00 	movl   $0x79,(%esp)
  8007be:	e8 5f fd ff ff       	call   800522 <syscall>
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <sys_getdirentry>:

int
sys_getdirentry(int fd, struct dirent *dirent) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getdirentry, fd, dirent);
  8007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	c7 04 24 80 00 00 00 	movl   $0x80,(%esp)
  8007e0:	e8 3d fd ff ff       	call   800522 <syscall>
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <sys_dup>:

int
sys_dup(int fd1, int fd2) {
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_dup, fd1, fd2);
  8007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	c7 04 24 82 00 00 00 	movl   $0x82,(%esp)
  800802:	e8 1b fd ff ff       	call   800522 <syscall>
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <try_lock>:
lock_init(lock_t *l) {
    *l = 0;
}

static inline bool
try_lock(lock_t *l) {
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 10             	sub    $0x10,%esp
  80080f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  80081c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80081f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800822:	0f ab 02             	bts    %eax,(%edx)
  800825:	19 c0                	sbb    %eax,%eax
  800827:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  80082a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80082e:	0f 95 c0             	setne  %al
  800831:	0f b6 c0             	movzbl %al,%eax
    return test_and_set_bit(0, l);
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <lock>:

static inline void
lock(lock_t *l) {
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	83 ec 28             	sub    $0x28,%esp
    if (try_lock(l)) {
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 c2 ff ff ff       	call   800809 <try_lock>
  800847:	85 c0                	test   %eax,%eax
  800849:	74 38                	je     800883 <lock+0x4d>
        int step = 0;
  80084b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        do {
            yield();
  800852:	e8 df 00 00 00       	call   800936 <yield>
            if (++ step == 100) {
  800857:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80085b:	83 7d f4 64          	cmpl   $0x64,-0xc(%ebp)
  80085f:	75 13                	jne    800874 <lock+0x3e>
                step = 0;
  800861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
                sleep(10);
  800868:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80086f:	e8 0f 01 00 00       	call   800983 <sleep>
            }
        } while (try_lock(l));
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	e8 8a ff ff ff       	call   800809 <try_lock>
  80087f:	85 c0                	test   %eax,%eax
  800881:	75 cf                	jne    800852 <lock+0x1c>
    }
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <unlock>:

static inline void
unlock(lock_t *l) {
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 10             	sub    $0x10,%esp
  80088b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  800898:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80089b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089e:	0f b3 02             	btr    %eax,(%edx)
  8008a1:	19 c0                	sbb    %eax,%eax
  8008a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  8008a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    test_and_clear_bit(0, l);
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <lock_fork>:
#include <lock.h>

static lock_t fork_lock = INIT_LOCK;

void
lock_fork(void) {
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 18             	sub    $0x18,%esp
    lock(&fork_lock);
  8008b2:	c7 04 24 24 20 80 00 	movl   $0x802024,(%esp)
  8008b9:	e8 78 ff ff ff       	call   800836 <lock>
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <unlock_fork>:

void
unlock_fork(void) {
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 04             	sub    $0x4,%esp
    unlock(&fork_lock);
  8008c6:	c7 04 24 24 20 80 00 	movl   $0x802024,(%esp)
  8008cd:	e8 b3 ff ff ff       	call   800885 <unlock>
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <exit>:

void
exit(int error_code) {
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	e8 93 fc ff ff       	call   800578 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8008e5:	c7 04 24 ac 19 80 00 	movl   $0x8019ac,(%esp)
  8008ec:	e8 20 fb ff ff       	call   800411 <cprintf>
    while (1);
  8008f1:	eb fe                	jmp    8008f1 <exit+0x1d>

008008f3 <fork>:
}

int
fork(void) {
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8008f9:	e8 95 fc ff ff       	call   800593 <sys_fork>
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <wait>:

int
wait(void) {
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800906:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80090d:	00 
  80090e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800915:	e8 8d fc ff ff       	call   8005a7 <sys_wait>
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <waitpid>:

int
waitpid(int pid, int *store) {
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	e8 73 fc ff ff       	call   8005a7 <sys_wait>
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <yield>:

void
yield(void) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  80093c:	e8 88 fc ff ff       	call   8005c9 <sys_yield>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <kill>:

int
kill(int pid) {
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 89 fc ff ff       	call   8005dd <sys_kill>
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <getpid>:

int
getpid(void) {
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  80095c:	e8 97 fc ff ff       	call   8005f8 <sys_getpid>
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800969:	e8 b9 fc ff ff       	call   800627 <sys_pgdir>
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 ba fc ff ff       	call   80063b <sys_lab6_set_priority>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <sleep>:

int
sleep(unsigned int time) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	83 ec 18             	sub    $0x18,%esp
    return sys_sleep(time);
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 c2 fc ff ff       	call   800656 <sys_sleep>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <gettime_msec>:

unsigned int
gettime_msec(void) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  80099c:	e8 d0 fc ff ff       	call   800671 <sys_gettime>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <__exec>:

int
__exec(const char *name, const char **argv) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  8009a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (argv[argc] != NULL) {
  8009b0:	eb 04                	jmp    8009b6 <__exec+0x13>
        argc ++;
  8009b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
}

int
__exec(const char *name, const char **argv) {
    int argc = 0;
    while (argv[argc] != NULL) {
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	01 d0                	add    %edx,%eax
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	85 c0                	test   %eax,%eax
  8009c9:	75 e7                	jne    8009b2 <__exec+0xf>
        argc ++;
    }
    return sys_exec(name, argc, argv);
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	89 04 24             	mov    %eax,(%esp)
  8009df:	e8 a1 fc ff ff       	call   800685 <sys_exec>
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <initfd>:
#include <stat.h>

int main(int argc, char *argv[]);

static int
initfd(int fd2, const char *path, uint32_t open_flags) {
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 28             	sub    $0x28,%esp
    int fd1, ret;
    if ((fd1 = open(path, open_flags)) < 0) {
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 fa f6 ff ff       	call   8000f8 <open>
  8009fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a05:	79 05                	jns    800a0c <initfd+0x26>
        return fd1;
  800a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0a:	eb 36                	jmp    800a42 <initfd+0x5c>
    }
    if (fd1 != fd2) {
  800a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0f:	3b 45 08             	cmp    0x8(%ebp),%eax
  800a12:	74 2b                	je     800a3f <initfd+0x59>
        close(fd2);
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 f3 f6 ff ff       	call   800112 <close>
        ret = dup2(fd1, fd2);
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a29:	89 04 24             	mov    %eax,(%esp)
  800a2c:	e8 b8 f7 ff ff       	call   8001e9 <dup2>
  800a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  800a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a37:	89 04 24             	mov    %eax,(%esp)
  800a3a:	e8 d3 f6 ff ff       	call   800112 <close>
    }
    return ret;
  800a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <umain>:

void
umain(int argc, char *argv[]) {
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	83 ec 28             	sub    $0x28,%esp
    int fd;
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
  800a4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a51:	00 
  800a52:	c7 44 24 04 bf 19 80 	movl   $0x8019bf,0x4(%esp)
  800a59:	00 
  800a5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a61:	e8 80 ff ff ff       	call   8009e6 <initfd>
  800a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a6d:	79 23                	jns    800a92 <umain+0x4e>
        warn("open <stdin> failed: %e.\n", fd);
  800a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a76:	c7 44 24 08 c6 19 80 	movl   $0x8019c6,0x8(%esp)
  800a7d:	00 
  800a7e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800a85:	00 
  800a86:	c7 04 24 e0 19 80 00 	movl   $0x8019e0,(%esp)
  800a8d:	e8 de f8 ff ff       	call   800370 <__warn>
    }
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
  800a92:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800a99:	00 
  800a9a:	c7 44 24 04 f2 19 80 	movl   $0x8019f2,0x4(%esp)
  800aa1:	00 
  800aa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800aa9:	e8 38 ff ff ff       	call   8009e6 <initfd>
  800aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ab1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800ab5:	79 23                	jns    800ada <umain+0x96>
        warn("open <stdout> failed: %e.\n", fd);
  800ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abe:	c7 44 24 08 fa 19 80 	movl   $0x8019fa,0x8(%esp)
  800ac5:	00 
  800ac6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800acd:	00 
  800ace:	c7 04 24 e0 19 80 00 	movl   $0x8019e0,(%esp)
  800ad5:	e8 96 f8 ff ff       	call   800370 <__warn>
    }
    int ret = main(argc, argv);
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	89 04 24             	mov    %eax,(%esp)
  800ae7:	e8 f1 0c 00 00       	call   8017dd <main>
  800aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    exit(ret);
  800aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 da fd ff ff       	call   8008d4 <exit>

00800afa <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800b09:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800b0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b11:	2b 45 0c             	sub    0xc(%ebp),%eax
  800b14:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b17:	89 c1                	mov    %eax,%ecx
  800b19:	d3 ea                	shr    %cl,%edx
  800b1b:	89 d0                	mov    %edx,%eax
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*, int), int fd, void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 58             	sub    $0x58,%esp
  800b25:	8b 45 14             	mov    0x14(%ebp),%eax
  800b28:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b2b:	8b 45 18             	mov    0x18(%ebp),%eax
  800b2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800b31:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b3a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800b3d:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b46:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b4c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b55:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b59:	74 1c                	je     800b77 <printnum+0x58>
  800b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	f7 75 e4             	divl   -0x1c(%ebp)
  800b66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	f7 75 e4             	divl   -0x1c(%ebp)
  800b74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7d:	f7 75 e4             	divl   -0x1c(%ebp)
  800b80:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b83:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b89:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b8f:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b92:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b95:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800b98:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800ba3:	77 64                	ja     800c09 <printnum+0xea>
  800ba5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800ba8:	72 05                	jb     800baf <printnum+0x90>
  800baa:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  800bad:	77 5a                	ja     800c09 <printnum+0xea>
        printnum(putch, fd, putdat, result, base, width - 1, padc);
  800baf:	8b 45 20             	mov    0x20(%ebp),%eax
  800bb2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb5:	8b 45 24             	mov    0x24(%ebp),%eax
  800bb8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800bbc:	89 54 24 18          	mov    %edx,0x18(%esp)
  800bc0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800bc3:	89 44 24 14          	mov    %eax,0x14(%esp)
  800bc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bca:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800bcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be3:	8b 45 08             	mov    0x8(%ebp),%eax
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	e8 31 ff ff ff       	call   800b1f <printnum>
  800bee:	eb 23                	jmp    800c13 <printnum+0xf4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat, fd);
  800bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfe:	8b 45 24             	mov    0x24(%ebp),%eax
  800c01:	89 04 24             	mov    %eax,(%esp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, fd, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800c09:	83 6d 20 01          	subl   $0x1,0x20(%ebp)
  800c0d:	83 7d 20 00          	cmpl   $0x0,0x20(%ebp)
  800c11:	7f dd                	jg     800bf0 <printnum+0xd1>
            putch(padc, putdat, fd);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat, fd);
  800c13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c16:	05 24 1c 80 00       	add    $0x801c24,%eax
  800c1b:	0f b6 00             	movzbl (%eax),%eax
  800c1e:	0f be c0             	movsbl %al,%eax
  800c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c24:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c28:	8b 55 10             	mov    0x10(%ebp),%edx
  800c2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c2f:	89 04 24             	mov    %eax,(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	ff d0                	call   *%eax
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c3c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c40:	7e 14                	jle    800c56 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	8b 00                	mov    (%eax),%eax
  800c47:	8d 48 08             	lea    0x8(%eax),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 0a                	mov    %ecx,(%edx)
  800c4f:	8b 50 04             	mov    0x4(%eax),%edx
  800c52:	8b 00                	mov    (%eax),%eax
  800c54:	eb 30                	jmp    800c86 <getuint+0x4d>
    }
    else if (lflag) {
  800c56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5a:	74 16                	je     800c72 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8b 00                	mov    (%eax),%eax
  800c61:	8d 48 04             	lea    0x4(%eax),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 0a                	mov    %ecx,(%edx)
  800c69:	8b 00                	mov    (%eax),%eax
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	eb 14                	jmp    800c86 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800c72:	8b 45 08             	mov    0x8(%ebp),%eax
  800c75:	8b 00                	mov    (%eax),%eax
  800c77:	8d 48 04             	lea    0x4(%eax),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 0a                	mov    %ecx,(%edx)
  800c7f:	8b 00                	mov    (%eax),%eax
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c8b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c8f:	7e 14                	jle    800ca5 <getint+0x1d>
        return va_arg(*ap, long long);
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8b 00                	mov    (%eax),%eax
  800c96:	8d 48 08             	lea    0x8(%eax),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 0a                	mov    %ecx,(%edx)
  800c9e:	8b 50 04             	mov    0x4(%eax),%edx
  800ca1:	8b 00                	mov    (%eax),%eax
  800ca3:	eb 28                	jmp    800ccd <getint+0x45>
    }
    else if (lflag) {
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 12                	je     800cbd <getint+0x35>
        return va_arg(*ap, long);
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 00                	mov    (%eax),%eax
  800cb0:	8d 48 04             	lea    0x4(%eax),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 0a                	mov    %ecx,(%edx)
  800cb8:	8b 00                	mov    (%eax),%eax
  800cba:	99                   	cltd   
  800cbb:	eb 10                	jmp    800ccd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	8b 00                	mov    (%eax),%eax
  800cc2:	8d 48 04             	lea    0x4(%eax),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 0a                	mov    %ecx,(%edx)
  800cca:	8b 00                	mov    (%eax),%eax
  800ccc:	99                   	cltd   
    }
}
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <printfmt>:
 * @fd:         file descriptor
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, ...) {
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 38             	sub    $0x38,%esp
    va_list ap;

    va_start(ap, fmt);
  800cd5:	8d 45 18             	lea    0x18(%ebp),%eax
  800cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, fd, putdat, fmt, ap);
  800cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cec:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	89 04 24             	mov    %eax,(%esp)
  800cfd:	e8 02 00 00 00       	call   800d04 <vprintfmt>
    va_end(ap);
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, va_list ap) {
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800d0c:	eb 1f                	jmp    800d2d <vprintfmt+0x29>
            if (ch == '\0') {
  800d0e:	85 db                	test   %ebx,%ebx
  800d10:	75 05                	jne    800d17 <vprintfmt+0x13>
                return;
  800d12:	e9 33 04 00 00       	jmp    80114a <vprintfmt+0x446>
            }
            putch(ch, putdat, fd);
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d25:	89 1c 24             	mov    %ebx,(%esp)
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800d2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d30:	8d 50 01             	lea    0x1(%eax),%edx
  800d33:	89 55 14             	mov    %edx,0x14(%ebp)
  800d36:	0f b6 00             	movzbl (%eax),%eax
  800d39:	0f b6 d8             	movzbl %al,%ebx
  800d3c:	83 fb 25             	cmp    $0x25,%ebx
  800d3f:	75 cd                	jne    800d0e <vprintfmt+0xa>
            }
            putch(ch, putdat, fd);
        }

        // Process a %-escape sequence
        char padc = ' ';
  800d41:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800d45:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800d52:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d59:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d5c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800d5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d62:	8d 50 01             	lea    0x1(%eax),%edx
  800d65:	89 55 14             	mov    %edx,0x14(%ebp)
  800d68:	0f b6 00             	movzbl (%eax),%eax
  800d6b:	0f b6 d8             	movzbl %al,%ebx
  800d6e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800d71:	83 f8 55             	cmp    $0x55,%eax
  800d74:	0f 87 98 03 00 00    	ja     801112 <vprintfmt+0x40e>
  800d7a:	8b 04 85 48 1c 80 00 	mov    0x801c48(,%eax,4),%eax
  800d81:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800d83:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800d87:	eb d6                	jmp    800d5f <vprintfmt+0x5b>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800d89:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800d8d:	eb d0                	jmp    800d5f <vprintfmt+0x5b>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800d8f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800d96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	c1 e0 02             	shl    $0x2,%eax
  800d9e:	01 d0                	add    %edx,%eax
  800da0:	01 c0                	add    %eax,%eax
  800da2:	01 d8                	add    %ebx,%eax
  800da4:	83 e8 30             	sub    $0x30,%eax
  800da7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800daa:	8b 45 14             	mov    0x14(%ebp),%eax
  800dad:	0f b6 00             	movzbl (%eax),%eax
  800db0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800db3:	83 fb 2f             	cmp    $0x2f,%ebx
  800db6:	7e 0b                	jle    800dc3 <vprintfmt+0xbf>
  800db8:	83 fb 39             	cmp    $0x39,%ebx
  800dbb:	7f 06                	jg     800dc3 <vprintfmt+0xbf>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800dbd:	83 45 14 01          	addl   $0x1,0x14(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  800dc1:	eb d3                	jmp    800d96 <vprintfmt+0x92>
            goto process_precision;
  800dc3:	eb 33                	jmp    800df8 <vprintfmt+0xf4>

        case '*':
            precision = va_arg(ap, int);
  800dc5:	8b 45 18             	mov    0x18(%ebp),%eax
  800dc8:	8d 50 04             	lea    0x4(%eax),%edx
  800dcb:	89 55 18             	mov    %edx,0x18(%ebp)
  800dce:	8b 00                	mov    (%eax),%eax
  800dd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800dd3:	eb 23                	jmp    800df8 <vprintfmt+0xf4>

        case '.':
            if (width < 0)
  800dd5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800dd9:	79 0c                	jns    800de7 <vprintfmt+0xe3>
                width = 0;
  800ddb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800de2:	e9 78 ff ff ff       	jmp    800d5f <vprintfmt+0x5b>
  800de7:	e9 73 ff ff ff       	jmp    800d5f <vprintfmt+0x5b>

        case '#':
            altflag = 1;
  800dec:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800df3:	e9 67 ff ff ff       	jmp    800d5f <vprintfmt+0x5b>

        process_precision:
            if (width < 0)
  800df8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800dfc:	79 12                	jns    800e10 <vprintfmt+0x10c>
                width = precision, precision = -1;
  800dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e01:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e04:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800e0b:	e9 4f ff ff ff       	jmp    800d5f <vprintfmt+0x5b>
  800e10:	e9 4a ff ff ff       	jmp    800d5f <vprintfmt+0x5b>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800e15:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800e19:	e9 41 ff ff ff       	jmp    800d5f <vprintfmt+0x5b>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat, fd);
  800e1e:	8b 45 18             	mov    0x18(%ebp),%eax
  800e21:	8d 50 04             	lea    0x4(%eax),%edx
  800e24:	89 55 18             	mov    %edx,0x18(%ebp)
  800e27:	8b 00                	mov    (%eax),%eax
  800e29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e30:	8b 55 10             	mov    0x10(%ebp),%edx
  800e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e37:	89 04 24             	mov    %eax,(%esp)
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	ff d0                	call   *%eax
            break;
  800e3f:	e9 00 03 00 00       	jmp    801144 <vprintfmt+0x440>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800e44:	8b 45 18             	mov    0x18(%ebp),%eax
  800e47:	8d 50 04             	lea    0x4(%eax),%edx
  800e4a:	89 55 18             	mov    %edx,0x18(%ebp)
  800e4d:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800e4f:	85 db                	test   %ebx,%ebx
  800e51:	79 02                	jns    800e55 <vprintfmt+0x151>
                err = -err;
  800e53:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800e55:	83 fb 18             	cmp    $0x18,%ebx
  800e58:	7f 0b                	jg     800e65 <vprintfmt+0x161>
  800e5a:	8b 34 9d c0 1b 80 00 	mov    0x801bc0(,%ebx,4),%esi
  800e61:	85 f6                	test   %esi,%esi
  800e63:	75 2a                	jne    800e8f <vprintfmt+0x18b>
                printfmt(putch, fd, putdat, "error %d", err);
  800e65:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e69:	c7 44 24 0c 35 1c 80 	movl   $0x801c35,0xc(%esp)
  800e70:	00 
  800e71:	8b 45 10             	mov    0x10(%ebp),%eax
  800e74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	89 04 24             	mov    %eax,(%esp)
  800e85:	e8 45 fe ff ff       	call   800ccf <printfmt>
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
            }
            break;
  800e8a:	e9 b5 02 00 00       	jmp    801144 <vprintfmt+0x440>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, fd, putdat, "error %d", err);
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
  800e8f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e93:	c7 44 24 0c 3e 1c 80 	movl   $0x801c3e,0xc(%esp)
  800e9a:	00 
  800e9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	89 04 24             	mov    %eax,(%esp)
  800eaf:	e8 1b fe ff ff       	call   800ccf <printfmt>
            }
            break;
  800eb4:	e9 8b 02 00 00       	jmp    801144 <vprintfmt+0x440>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800eb9:	8b 45 18             	mov    0x18(%ebp),%eax
  800ebc:	8d 50 04             	lea    0x4(%eax),%edx
  800ebf:	89 55 18             	mov    %edx,0x18(%ebp)
  800ec2:	8b 30                	mov    (%eax),%esi
  800ec4:	85 f6                	test   %esi,%esi
  800ec6:	75 05                	jne    800ecd <vprintfmt+0x1c9>
                p = "(null)";
  800ec8:	be 41 1c 80 00       	mov    $0x801c41,%esi
            }
            if (width > 0 && padc != '-') {
  800ecd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800ed1:	7e 45                	jle    800f18 <vprintfmt+0x214>
  800ed3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800ed7:	74 3f                	je     800f18 <vprintfmt+0x214>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800ed9:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800edf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee3:	89 34 24             	mov    %esi,(%esp)
  800ee6:	e8 3b 04 00 00       	call   801326 <strnlen>
  800eeb:	29 c3                	sub    %eax,%ebx
  800eed:	89 d8                	mov    %ebx,%eax
  800eef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ef2:	eb 1e                	jmp    800f12 <vprintfmt+0x20e>
                    putch(padc, putdat, fd);
  800ef4:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800ef8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eff:	8b 55 10             	mov    0x10(%ebp),%edx
  800f02:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  800f0e:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f12:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f16:	7f dc                	jg     800ef4 <vprintfmt+0x1f0>
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800f18:	eb 46                	jmp    800f60 <vprintfmt+0x25c>
                if (altflag && (ch < ' ' || ch > '~')) {
  800f1a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f1e:	74 26                	je     800f46 <vprintfmt+0x242>
  800f20:	83 fb 1f             	cmp    $0x1f,%ebx
  800f23:	7e 05                	jle    800f2a <vprintfmt+0x226>
  800f25:	83 fb 7e             	cmp    $0x7e,%ebx
  800f28:	7e 1c                	jle    800f46 <vprintfmt+0x242>
                    putch('?', putdat, fd);
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f31:	8b 45 10             	mov    0x10(%ebp),%eax
  800f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f38:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	ff d0                	call   *%eax
  800f44:	eb 16                	jmp    800f5c <vprintfmt+0x258>
                }
                else {
                    putch(ch, putdat, fd);
  800f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f54:	89 1c 24             	mov    %ebx,(%esp)
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5a:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800f5c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	8d 70 01             	lea    0x1(%eax),%esi
  800f65:	0f b6 00             	movzbl (%eax),%eax
  800f68:	0f be d8             	movsbl %al,%ebx
  800f6b:	85 db                	test   %ebx,%ebx
  800f6d:	74 10                	je     800f7f <vprintfmt+0x27b>
  800f6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f73:	78 a5                	js     800f1a <vprintfmt+0x216>
  800f75:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800f79:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f7d:	79 9b                	jns    800f1a <vprintfmt+0x216>
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f7f:	eb 1e                	jmp    800f9f <vprintfmt+0x29b>
                putch(' ', putdat, fd);
  800f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f88:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f9b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f9f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800fa3:	7f dc                	jg     800f81 <vprintfmt+0x27d>
                putch(' ', putdat, fd);
            }
            break;
  800fa5:	e9 9a 01 00 00       	jmp    801144 <vprintfmt+0x440>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb1:	8d 45 18             	lea    0x18(%ebp),%eax
  800fb4:	89 04 24             	mov    %eax,(%esp)
  800fb7:	e8 cc fc ff ff       	call   800c88 <getint>
  800fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fc8:	85 d2                	test   %edx,%edx
  800fca:	79 2d                	jns    800ff9 <vprintfmt+0x2f5>
                putch('-', putdat, fd);
  800fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fda:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	ff d0                	call   *%eax
                num = -(long long)num;
  800fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fec:	f7 d8                	neg    %eax
  800fee:	83 d2 00             	adc    $0x0,%edx
  800ff1:	f7 da                	neg    %edx
  800ff3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ff6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800ff9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  801000:	e9 b6 00 00 00       	jmp    8010bb <vprintfmt+0x3b7>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  801005:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100c:	8d 45 18             	lea    0x18(%ebp),%eax
  80100f:	89 04 24             	mov    %eax,(%esp)
  801012:	e8 22 fc ff ff       	call   800c39 <getuint>
  801017:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80101a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  80101d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  801024:	e9 92 00 00 00       	jmp    8010bb <vprintfmt+0x3b7>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  801029:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801030:	8d 45 18             	lea    0x18(%ebp),%eax
  801033:	89 04 24             	mov    %eax,(%esp)
  801036:	e8 fe fb ff ff       	call   800c39 <getuint>
  80103b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80103e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  801041:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  801048:	eb 71                	jmp    8010bb <vprintfmt+0x3b7>

        // pointer
        case 'p':
            putch('0', putdat, fd);
  80104a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801051:	8b 45 10             	mov    0x10(%ebp),%eax
  801054:	89 44 24 04          	mov    %eax,0x4(%esp)
  801058:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80105f:	8b 45 08             	mov    0x8(%ebp),%eax
  801062:	ff d0                	call   *%eax
            putch('x', putdat, fd);
  801064:	8b 45 0c             	mov    0xc(%ebp),%eax
  801067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106b:	8b 45 10             	mov    0x10(%ebp),%eax
  80106e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801072:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80107e:	8b 45 18             	mov    0x18(%ebp),%eax
  801081:	8d 50 04             	lea    0x4(%eax),%edx
  801084:	89 55 18             	mov    %edx,0x18(%ebp)
  801087:	8b 00                	mov    (%eax),%eax
  801089:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80108c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  801093:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  80109a:	eb 1f                	jmp    8010bb <vprintfmt+0x3b7>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  80109c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80109f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a3:	8d 45 18             	lea    0x18(%ebp),%eax
  8010a6:	89 04 24             	mov    %eax,(%esp)
  8010a9:	e8 8b fb ff ff       	call   800c39 <getuint>
  8010ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  8010b4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, fd, putdat, num, base, width, padc);
  8010bb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8010bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010c2:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  8010c6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8010c9:	89 54 24 18          	mov    %edx,0x18(%esp)
  8010cd:	89 44 24 14          	mov    %eax,0x14(%esp)
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010db:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010df:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	89 04 24             	mov    %eax,(%esp)
  8010f3:	e8 27 fa ff ff       	call   800b1f <printnum>
            break;
  8010f8:	eb 4a                	jmp    801144 <vprintfmt+0x440>

        // escaped '%' character
        case '%':
            putch(ch, putdat, fd);
  8010fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801101:	8b 45 10             	mov    0x10(%ebp),%eax
  801104:	89 44 24 04          	mov    %eax,0x4(%esp)
  801108:	89 1c 24             	mov    %ebx,(%esp)
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	ff d0                	call   *%eax
            break;
  801110:	eb 32                	jmp    801144 <vprintfmt+0x440>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat, fd);
  801112:	8b 45 0c             	mov    0xc(%ebp),%eax
  801115:	89 44 24 08          	mov    %eax,0x8(%esp)
  801119:	8b 45 10             	mov    0x10(%ebp),%eax
  80111c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801120:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  80112c:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801130:	eb 04                	jmp    801136 <vprintfmt+0x432>
  801132:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801136:	8b 45 14             	mov    0x14(%ebp),%eax
  801139:	83 e8 01             	sub    $0x1,%eax
  80113c:	0f b6 00             	movzbl (%eax),%eax
  80113f:	3c 25                	cmp    $0x25,%al
  801141:	75 ef                	jne    801132 <vprintfmt+0x42e>
                /* do nothing */;
            break;
  801143:	90                   	nop
        }
    }
  801144:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  801145:	e9 e3 fb ff ff       	jmp    800d2d <vprintfmt+0x29>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80114a:	83 c4 40             	add    $0x40,%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  801154:	8b 45 0c             	mov    0xc(%ebp),%eax
  801157:	8b 40 08             	mov    0x8(%eax),%eax
  80115a:	8d 50 01             	lea    0x1(%eax),%edx
  80115d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801160:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  801163:	8b 45 0c             	mov    0xc(%ebp),%eax
  801166:	8b 10                	mov    (%eax),%edx
  801168:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116b:	8b 40 04             	mov    0x4(%eax),%eax
  80116e:	39 c2                	cmp    %eax,%edx
  801170:	73 12                	jae    801184 <sprintputch+0x33>
        *b->buf ++ = ch;
  801172:	8b 45 0c             	mov    0xc(%ebp),%eax
  801175:	8b 00                	mov    (%eax),%eax
  801177:	8d 48 01             	lea    0x1(%eax),%ecx
  80117a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117d:	89 0a                	mov    %ecx,(%edx)
  80117f:	8b 55 08             	mov    0x8(%ebp),%edx
  801182:	88 10                	mov    %dl,(%eax)
    }
}
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  80118c:	8d 45 14             	lea    0x14(%ebp),%eax
  80118f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801199:	8b 45 10             	mov    0x10(%ebp),%eax
  80119c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 08 00 00 00       	call   8011ba <vsnprintf>
  8011b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  8011b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 38             	sub    $0x38,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	01 d0                	add    %edx,%eax
  8011d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8011d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  8011db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011df:	74 0a                	je     8011eb <vsnprintf+0x31>
  8011e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	39 c2                	cmp    %eax,%edx
  8011e9:	76 07                	jbe    8011f2 <vsnprintf+0x38>
        return -E_INVAL;
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f0:	eb 32                	jmp    801224 <vsnprintf+0x6a>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, NO_FD, &b, fmt, ap);
  8011f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8011f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801200:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801203:	89 44 24 08          	mov    %eax,0x8(%esp)
  801207:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  80120e:	ff 
  80120f:	c7 04 24 51 11 80 00 	movl   $0x801151,(%esp)
  801216:	e8 e9 fa ff ff       	call   800d04 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80121b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80121e:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  801221:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	57                   	push   %edi
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
  80122c:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  80122f:	a1 08 20 80 00       	mov    0x802008,%eax
  801234:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  80123a:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  801240:	6b f0 05             	imul   $0x5,%eax,%esi
  801243:	01 f7                	add    %esi,%edi
  801245:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  80124a:	f7 e6                	mul    %esi
  80124c:	8d 34 17             	lea    (%edi,%edx,1),%esi
  80124f:	89 f2                	mov    %esi,%edx
  801251:	83 c0 0b             	add    $0xb,%eax
  801254:	83 d2 00             	adc    $0x0,%edx
  801257:	89 c7                	mov    %eax,%edi
  801259:	83 e7 ff             	and    $0xffffffff,%edi
  80125c:	89 f9                	mov    %edi,%ecx
  80125e:	0f b7 da             	movzwl %dx,%ebx
  801261:	89 0d 08 20 80 00    	mov    %ecx,0x802008
  801267:	89 1d 0c 20 80 00    	mov    %ebx,0x80200c
    unsigned long long result = (next >> 12);
  80126d:	a1 08 20 80 00       	mov    0x802008,%eax
  801272:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801278:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  80127c:	c1 ea 0c             	shr    $0xc,%edx
  80127f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801282:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  801285:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  80128c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801292:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801295:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801298:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80129b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80129e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012a2:	74 1c                	je     8012c0 <rand+0x9a>
  8012a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ac:	f7 75 dc             	divl   -0x24(%ebp)
  8012af:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ba:	f7 75 dc             	divl   -0x24(%ebp)
  8012bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8012c6:	f7 75 dc             	divl   -0x24(%ebp)
  8012c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012d2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012de:	83 c4 24             	add    $0x24,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
    next = seed;
  8012e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	a3 08 20 80 00       	mov    %eax,0x802008
  8012f6:	89 15 0c 20 80 00    	mov    %edx,0x80200c
}
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  801304:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  80130b:	eb 04                	jmp    801311 <strlen+0x13>
        cnt ++;
  80130d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	8d 50 01             	lea    0x1(%eax),%edx
  801317:	89 55 08             	mov    %edx,0x8(%ebp)
  80131a:	0f b6 00             	movzbl (%eax),%eax
  80131d:	84 c0                	test   %al,%al
  80131f:	75 ec                	jne    80130d <strlen+0xf>
        cnt ++;
    }
    return cnt;
  801321:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  80132c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  801333:	eb 04                	jmp    801339 <strnlen+0x13>
        cnt ++;
  801335:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  801339:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80133c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80133f:	73 10                	jae    801351 <strnlen+0x2b>
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	8d 50 01             	lea    0x1(%eax),%edx
  801347:	89 55 08             	mov    %edx,0x8(%ebp)
  80134a:	0f b6 00             	movzbl (%eax),%eax
  80134d:	84 c0                	test   %al,%al
  80134f:	75 e4                	jne    801335 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  801351:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <strcat>:
 * @dst:    pointer to the @dst array, which should be large enough to contain the concatenated
 *          resulting string.
 * @src:    string to be appended, this should not overlap @dst
 * */
char *
strcat(char *dst, const char *src) {
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 18             	sub    $0x18,%esp
    return strcpy(dst + strlen(dst), src);
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 97 ff ff ff       	call   8012fe <strlen>
  801367:	8b 55 08             	mov    0x8(%ebp),%edx
  80136a:	01 c2                	add    %eax,%edx
  80136c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	89 14 24             	mov    %edx,(%esp)
  801376:	e8 02 00 00 00       	call   80137d <strcpy>
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	83 ec 20             	sub    $0x20,%esp
  801385:	8b 45 08             	mov    0x8(%ebp),%eax
  801388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  801391:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801397:	89 d1                	mov    %edx,%ecx
  801399:	89 c2                	mov    %eax,%edx
  80139b:	89 ce                	mov    %ecx,%esi
  80139d:	89 d7                	mov    %edx,%edi
  80139f:	ac                   	lods   %ds:(%esi),%al
  8013a0:	aa                   	stos   %al,%es:(%edi)
  8013a1:	84 c0                	test   %al,%al
  8013a3:	75 fa                	jne    80139f <strcpy+0x22>
  8013a5:	89 fa                	mov    %edi,%edx
  8013a7:	89 f1                	mov    %esi,%ecx
  8013a9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8013ac:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8013af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  8013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  8013b5:	83 c4 20             	add    $0x20,%esp
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  8013c8:	eb 21                	jmp    8013eb <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  8013ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cd:	0f b6 10             	movzbl (%eax),%edx
  8013d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d3:	88 10                	mov    %dl,(%eax)
  8013d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d8:	0f b6 00             	movzbl (%eax),%eax
  8013db:	84 c0                	test   %al,%al
  8013dd:	74 04                	je     8013e3 <strncpy+0x27>
            src ++;
  8013df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  8013e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8013e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  8013eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ef:	75 d9                	jne    8013ca <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	57                   	push   %edi
  8013fa:	56                   	push   %esi
  8013fb:	83 ec 20             	sub    $0x20,%esp
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801404:	8b 45 0c             	mov    0xc(%ebp),%eax
  801407:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  80140a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801410:	89 d1                	mov    %edx,%ecx
  801412:	89 c2                	mov    %eax,%edx
  801414:	89 ce                	mov    %ecx,%esi
  801416:	89 d7                	mov    %edx,%edi
  801418:	ac                   	lods   %ds:(%esi),%al
  801419:	ae                   	scas   %es:(%edi),%al
  80141a:	75 08                	jne    801424 <strcmp+0x2e>
  80141c:	84 c0                	test   %al,%al
  80141e:	75 f8                	jne    801418 <strcmp+0x22>
  801420:	31 c0                	xor    %eax,%eax
  801422:	eb 04                	jmp    801428 <strcmp+0x32>
  801424:	19 c0                	sbb    %eax,%eax
  801426:	0c 01                	or     $0x1,%al
  801428:	89 fa                	mov    %edi,%edx
  80142a:	89 f1                	mov    %esi,%ecx
  80142c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80142f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  801432:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  801435:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  801442:	eb 0c                	jmp    801450 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  801444:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  801448:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80144c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  801450:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801454:	74 1a                	je     801470 <strncmp+0x31>
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	0f b6 00             	movzbl (%eax),%eax
  80145c:	84 c0                	test   %al,%al
  80145e:	74 10                	je     801470 <strncmp+0x31>
  801460:	8b 45 08             	mov    0x8(%ebp),%eax
  801463:	0f b6 10             	movzbl (%eax),%edx
  801466:	8b 45 0c             	mov    0xc(%ebp),%eax
  801469:	0f b6 00             	movzbl (%eax),%eax
  80146c:	38 c2                	cmp    %al,%dl
  80146e:	74 d4                	je     801444 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  801470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801474:	74 18                	je     80148e <strncmp+0x4f>
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	0f b6 00             	movzbl (%eax),%eax
  80147c:	0f b6 d0             	movzbl %al,%edx
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	0f b6 00             	movzbl (%eax),%eax
  801485:	0f b6 c0             	movzbl %al,%eax
  801488:	29 c2                	sub    %eax,%edx
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	eb 05                	jmp    801493 <strncmp+0x54>
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8014a1:	eb 14                	jmp    8014b7 <strchr+0x22>
        if (*s == c) {
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	0f b6 00             	movzbl (%eax),%eax
  8014a9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8014ac:	75 05                	jne    8014b3 <strchr+0x1e>
            return (char *)s;
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	eb 13                	jmp    8014c6 <strchr+0x31>
        }
        s ++;
  8014b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	0f b6 00             	movzbl (%eax),%eax
  8014bd:	84 c0                	test   %al,%al
  8014bf:	75 e2                	jne    8014a3 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  8014c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8014d4:	eb 11                	jmp    8014e7 <strfind+0x1f>
        if (*s == c) {
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	0f b6 00             	movzbl (%eax),%eax
  8014dc:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8014df:	75 02                	jne    8014e3 <strfind+0x1b>
            break;
  8014e1:	eb 0e                	jmp    8014f1 <strfind+0x29>
        }
        s ++;
  8014e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	0f b6 00             	movzbl (%eax),%eax
  8014ed:	84 c0                	test   %al,%al
  8014ef:	75 e5                	jne    8014d6 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  8014fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  801503:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  80150a:	eb 04                	jmp    801510 <strtol+0x1a>
        s ++;
  80150c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	0f b6 00             	movzbl (%eax),%eax
  801516:	3c 20                	cmp    $0x20,%al
  801518:	74 f2                	je     80150c <strtol+0x16>
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	0f b6 00             	movzbl (%eax),%eax
  801520:	3c 09                	cmp    $0x9,%al
  801522:	74 e8                	je     80150c <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	0f b6 00             	movzbl (%eax),%eax
  80152a:	3c 2b                	cmp    $0x2b,%al
  80152c:	75 06                	jne    801534 <strtol+0x3e>
        s ++;
  80152e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801532:	eb 15                	jmp    801549 <strtol+0x53>
    }
    else if (*s == '-') {
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	0f b6 00             	movzbl (%eax),%eax
  80153a:	3c 2d                	cmp    $0x2d,%al
  80153c:	75 0b                	jne    801549 <strtol+0x53>
        s ++, neg = 1;
  80153e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801542:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  801549:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80154d:	74 06                	je     801555 <strtol+0x5f>
  80154f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801553:	75 24                	jne    801579 <strtol+0x83>
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	0f b6 00             	movzbl (%eax),%eax
  80155b:	3c 30                	cmp    $0x30,%al
  80155d:	75 1a                	jne    801579 <strtol+0x83>
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	83 c0 01             	add    $0x1,%eax
  801565:	0f b6 00             	movzbl (%eax),%eax
  801568:	3c 78                	cmp    $0x78,%al
  80156a:	75 0d                	jne    801579 <strtol+0x83>
        s += 2, base = 16;
  80156c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801570:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801577:	eb 2a                	jmp    8015a3 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  801579:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80157d:	75 17                	jne    801596 <strtol+0xa0>
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	0f b6 00             	movzbl (%eax),%eax
  801585:	3c 30                	cmp    $0x30,%al
  801587:	75 0d                	jne    801596 <strtol+0xa0>
        s ++, base = 8;
  801589:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80158d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801594:	eb 0d                	jmp    8015a3 <strtol+0xad>
    }
    else if (base == 0) {
  801596:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80159a:	75 07                	jne    8015a3 <strtol+0xad>
        base = 10;
  80159c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	0f b6 00             	movzbl (%eax),%eax
  8015a9:	3c 2f                	cmp    $0x2f,%al
  8015ab:	7e 1b                	jle    8015c8 <strtol+0xd2>
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	0f b6 00             	movzbl (%eax),%eax
  8015b3:	3c 39                	cmp    $0x39,%al
  8015b5:	7f 11                	jg     8015c8 <strtol+0xd2>
            dig = *s - '0';
  8015b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ba:	0f b6 00             	movzbl (%eax),%eax
  8015bd:	0f be c0             	movsbl %al,%eax
  8015c0:	83 e8 30             	sub    $0x30,%eax
  8015c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015c6:	eb 48                	jmp    801610 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	0f b6 00             	movzbl (%eax),%eax
  8015ce:	3c 60                	cmp    $0x60,%al
  8015d0:	7e 1b                	jle    8015ed <strtol+0xf7>
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	0f b6 00             	movzbl (%eax),%eax
  8015d8:	3c 7a                	cmp    $0x7a,%al
  8015da:	7f 11                	jg     8015ed <strtol+0xf7>
            dig = *s - 'a' + 10;
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	0f b6 00             	movzbl (%eax),%eax
  8015e2:	0f be c0             	movsbl %al,%eax
  8015e5:	83 e8 57             	sub    $0x57,%eax
  8015e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015eb:	eb 23                	jmp    801610 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	0f b6 00             	movzbl (%eax),%eax
  8015f3:	3c 40                	cmp    $0x40,%al
  8015f5:	7e 3d                	jle    801634 <strtol+0x13e>
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	0f b6 00             	movzbl (%eax),%eax
  8015fd:	3c 5a                	cmp    $0x5a,%al
  8015ff:	7f 33                	jg     801634 <strtol+0x13e>
            dig = *s - 'A' + 10;
  801601:	8b 45 08             	mov    0x8(%ebp),%eax
  801604:	0f b6 00             	movzbl (%eax),%eax
  801607:	0f be c0             	movsbl %al,%eax
  80160a:	83 e8 37             	sub    $0x37,%eax
  80160d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  801610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801613:	3b 45 10             	cmp    0x10(%ebp),%eax
  801616:	7c 02                	jl     80161a <strtol+0x124>
            break;
  801618:	eb 1a                	jmp    801634 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  80161a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80161e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801621:	0f af 45 10          	imul   0x10(%ebp),%eax
  801625:	89 c2                	mov    %eax,%edx
  801627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162a:	01 d0                	add    %edx,%eax
  80162c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  80162f:	e9 6f ff ff ff       	jmp    8015a3 <strtol+0xad>

    if (endptr) {
  801634:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801638:	74 08                	je     801642 <strtol+0x14c>
        *endptr = (char *) s;
  80163a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163d:	8b 55 08             	mov    0x8(%ebp),%edx
  801640:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  801642:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801646:	74 07                	je     80164f <strtol+0x159>
  801648:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80164b:	f7 d8                	neg    %eax
  80164d:	eb 03                	jmp    801652 <strtol+0x15c>
  80164f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	83 ec 24             	sub    $0x24,%esp
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  801661:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801665:	8b 55 08             	mov    0x8(%ebp),%edx
  801668:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80166b:	88 45 f7             	mov    %al,-0x9(%ebp)
  80166e:	8b 45 10             	mov    0x10(%ebp),%eax
  801671:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  801674:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801677:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80167b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80167e:	89 d7                	mov    %edx,%edi
  801680:	f3 aa                	rep stos %al,%es:(%edi)
  801682:	89 fa                	mov    %edi,%edx
  801684:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  801687:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  80168a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  80168d:	83 c4 24             	add    $0x24,%esp
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	57                   	push   %edi
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	83 ec 30             	sub    $0x30,%esp
  80169c:	8b 45 08             	mov    0x8(%ebp),%eax
  80169f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ab:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  8016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8016b4:	73 42                	jae    8016f8 <memmove+0x65>
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8016c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016cb:	c1 e8 02             	shr    $0x2,%eax
  8016ce:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  8016d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d6:	89 d7                	mov    %edx,%edi
  8016d8:	89 c6                	mov    %eax,%esi
  8016da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016dc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016df:	83 e1 03             	and    $0x3,%ecx
  8016e2:	74 02                	je     8016e6 <memmove+0x53>
  8016e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8016e6:	89 f0                	mov    %esi,%eax
  8016e8:	89 fa                	mov    %edi,%edx
  8016ea:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016ed:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8016f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  8016f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f6:	eb 36                	jmp    80172e <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  8016f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016fb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8016fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801701:	01 c2                	add    %eax,%edx
  801703:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801706:	8d 48 ff             	lea    -0x1(%eax),%ecx
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  80170f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801712:	89 c1                	mov    %eax,%ecx
  801714:	89 d8                	mov    %ebx,%eax
  801716:	89 d6                	mov    %edx,%esi
  801718:	89 c7                	mov    %eax,%edi
  80171a:	fd                   	std    
  80171b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80171d:	fc                   	cld    
  80171e:	89 f8                	mov    %edi,%eax
  801720:	89 f2                	mov    %esi,%edx
  801722:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801725:	89 55 c8             	mov    %edx,-0x38(%ebp)
  801728:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  80172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  80172e:	83 c4 30             	add    $0x30,%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	83 ec 20             	sub    $0x20,%esp
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801744:	8b 45 0c             	mov    0xc(%ebp),%eax
  801747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80174a:	8b 45 10             	mov    0x10(%ebp),%eax
  80174d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  801750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801753:	c1 e8 02             	shr    $0x2,%eax
  801756:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  801758:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175e:	89 d7                	mov    %edx,%edi
  801760:	89 c6                	mov    %eax,%esi
  801762:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801764:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801767:	83 e1 03             	and    $0x3,%ecx
  80176a:	74 02                	je     80176e <memcpy+0x38>
  80176c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80176e:	89 f0                	mov    %esi,%eax
  801770:	89 fa                	mov    %edi,%edx
  801772:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  801775:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801778:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  80177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  80177e:	83 c4 20             	add    $0x20,%esp
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  80178b:	8b 45 08             	mov    0x8(%ebp),%eax
  80178e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  801791:	8b 45 0c             	mov    0xc(%ebp),%eax
  801794:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  801797:	eb 30                	jmp    8017c9 <memcmp+0x44>
        if (*s1 != *s2) {
  801799:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80179c:	0f b6 10             	movzbl (%eax),%edx
  80179f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8017a2:	0f b6 00             	movzbl (%eax),%eax
  8017a5:	38 c2                	cmp    %al,%dl
  8017a7:	74 18                	je     8017c1 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  8017a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ac:	0f b6 00             	movzbl (%eax),%eax
  8017af:	0f b6 d0             	movzbl %al,%edx
  8017b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8017b5:	0f b6 00             	movzbl (%eax),%eax
  8017b8:	0f b6 c0             	movzbl %al,%eax
  8017bb:	29 c2                	sub    %eax,%edx
  8017bd:	89 d0                	mov    %edx,%eax
  8017bf:	eb 1a                	jmp    8017db <memcmp+0x56>
        }
        s1 ++, s2 ++;
  8017c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8017c5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  8017c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017cc:	8d 50 ff             	lea    -0x1(%eax),%edx
  8017cf:	89 55 10             	mov    %edx,0x10(%ebp)
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	75 c3                	jne    801799 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 e4 f0             	and    $0xfffffff0,%esp
  8017e3:	83 ec 20             	sub    $0x20,%esp
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  8017e6:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  8017ed:	00 
  8017ee:	eb 60                	jmp    801850 <main+0x73>
        if ((pid = fork()) == 0) {
  8017f0:	e8 fe f0 ff ff       	call   8008f3 <fork>
  8017f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8017f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  8017fe:	75 20                	jne    801820 <main+0x43>
            cprintf("I am child %d\n", n);
  801800:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	c7 04 24 a4 1d 80 00 	movl   $0x801da4,(%esp)
  80180f:	e8 fd eb ff ff       	call   800411 <cprintf>
            exit(0);
  801814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181b:	e8 b4 f0 ff ff       	call   8008d4 <exit>
        }
        assert(pid > 0);
  801820:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  801825:	7f 24                	jg     80184b <main+0x6e>
  801827:	c7 44 24 0c b3 1d 80 	movl   $0x801db3,0xc(%esp)
  80182e:	00 
  80182f:	c7 44 24 08 bb 1d 80 	movl   $0x801dbb,0x8(%esp)
  801836:	00 
  801837:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80183e:	00 
  80183f:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  801846:	e8 d5 ea ff ff       	call   800320 <__panic>
const int max_child = 32;

int
main(void) {
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  80184b:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  801850:	b8 20 00 00 00       	mov    $0x20,%eax
  801855:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801859:	7c 95                	jl     8017f0 <main+0x13>
            exit(0);
        }
        assert(pid > 0);
    }

    if (n > max_child) {
  80185b:	b8 20 00 00 00       	mov    $0x20,%eax
  801860:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801864:	7e 24                	jle    80188a <main+0xad>
        panic("fork claimed to work %d times!\n", n);
  801866:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80186a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186e:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  801875:	00 
  801876:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80187d:	00 
  80187e:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  801885:	e8 96 ea ff ff       	call   800320 <__panic>
    }

    for (; n > 0; n --) {
  80188a:	eb 2a                	jmp    8018b6 <main+0xd9>
        if (wait() != 0) {
  80188c:	e8 6f f0 ff ff       	call   800900 <wait>
  801891:	85 c0                	test   %eax,%eax
  801893:	74 1c                	je     8018b1 <main+0xd4>
            panic("wait stopped early\n");
  801895:	c7 44 24 08 00 1e 80 	movl   $0x801e00,0x8(%esp)
  80189c:	00 
  80189d:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8018a4:	00 
  8018a5:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  8018ac:	e8 6f ea ff ff       	call   800320 <__panic>

    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
  8018b1:	83 6c 24 1c 01       	subl   $0x1,0x1c(%esp)
  8018b6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8018bb:	7f cf                	jg     80188c <main+0xaf>
        if (wait() != 0) {
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  8018bd:	e8 3e f0 ff ff       	call   800900 <wait>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	75 1c                	jne    8018e2 <main+0x105>
        panic("wait got too many\n");
  8018c6:	c7 44 24 08 14 1e 80 	movl   $0x801e14,0x8(%esp)
  8018cd:	00 
  8018ce:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8018d5:	00 
  8018d6:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  8018dd:	e8 3e ea ff ff       	call   800320 <__panic>
    }

    cprintf("forktest pass.\n");
  8018e2:	c7 04 24 27 1e 80 00 	movl   $0x801e27,(%esp)
  8018e9:	e8 23 eb ff ff       	call   800411 <cprintf>
    return 0;
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    
