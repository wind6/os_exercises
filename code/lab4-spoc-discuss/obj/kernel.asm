
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 c0 11 00 	lgdtl  0x11c018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 c0 11 c0       	mov    $0xc011c000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:

int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba d8 d9 11 c0       	mov    $0xc011d9d8,%edx
c0100035:	b8 68 ca 11 c0       	mov    $0xc011ca68,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 68 ca 11 c0 	movl   $0xc011ca68,(%esp)
c0100051:	e8 d3 70 00 00       	call   c0107129 <memset>

    cons_init();                // init the console
c0100056:	e8 08 14 00 00       	call   c0101463 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 c0 72 10 c0 	movl   $0xc01072c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 dc 72 10 c0 	movl   $0xc01072dc,(%esp)
c0100070:	e8 52 01 00 00       	call   c01001c7 <cprintf>

    print_kerninfo();
c0100075:	e8 81 06 00 00       	call   c01006fb <print_kerninfo>
    pmm_init();                 // init physical memory management
c010007a:	e8 45 46 00 00       	call   c01046c4 <pmm_init>
    pic_init();                 // init interrupt controller
c010007f:	e8 48 15 00 00       	call   c01015cc <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100084:	e8 9a 16 00 00       	call   c0101723 <idt_init>
    proc_init();                // init process table
c0100089:	e8 e4 61 00 00       	call   c0106272 <proc_init>
    clock_init();               // init clock interrupt
c010008e:	e8 86 0b 00 00       	call   c0100c19 <clock_init>
    intr_enable();              // enable irq interrupt
c0100093:	e8 a2 14 00 00       	call   c010153a <intr_enable>

	schedule();   //let init proc run
c0100098:	e8 10 65 00 00       	call   c01065ad <schedule>
	while (do_wait(1, NULL) == 0) {
c010009d:	eb 05                	jmp    c01000a4 <kern_init+0x7a>
        schedule();
c010009f:	e8 09 65 00 00       	call   c01065ad <schedule>
    proc_init();                // init process table
    clock_init();               // init clock interrupt
    intr_enable();              // enable irq interrupt

	schedule();   //let init proc run
	while (do_wait(1, NULL) == 0) {
c01000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ab:	00 
c01000ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01000b3:	e8 0a 5f 00 00       	call   c0105fc2 <do_wait>
c01000b8:	85 c0                	test   %eax,%eax
c01000ba:	74 e3                	je     c010009f <kern_init+0x75>
        schedule();
    }
}
c01000bc:	c9                   	leave  
c01000bd:	c3                   	ret    

c01000be <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c01000be:	55                   	push   %ebp
c01000bf:	89 e5                	mov    %esp,%ebp
c01000c1:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c01000c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01000c8:	74 13                	je     c01000dd <readline+0x1f>
        cprintf("%s", prompt);
c01000ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01000d1:	c7 04 24 e1 72 10 c0 	movl   $0xc01072e1,(%esp)
c01000d8:	e8 ea 00 00 00       	call   c01001c7 <cprintf>
    }
    int i = 0, c;
c01000dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01000e4:	e8 66 01 00 00       	call   c010024f <getchar>
c01000e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01000ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01000f0:	79 07                	jns    c01000f9 <readline+0x3b>
            return NULL;
c01000f2:	b8 00 00 00 00       	mov    $0x0,%eax
c01000f7:	eb 79                	jmp    c0100172 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01000f9:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01000fd:	7e 28                	jle    c0100127 <readline+0x69>
c01000ff:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100106:	7f 1f                	jg     c0100127 <readline+0x69>
            cputchar(c);
c0100108:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010010b:	89 04 24             	mov    %eax,(%esp)
c010010e:	e8 da 00 00 00       	call   c01001ed <cputchar>
            buf[i ++] = c;
c0100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100116:	8d 50 01             	lea    0x1(%eax),%edx
c0100119:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010011c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010011f:	88 90 80 ca 11 c0    	mov    %dl,-0x3fee3580(%eax)
c0100125:	eb 46                	jmp    c010016d <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c0100127:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010012b:	75 17                	jne    c0100144 <readline+0x86>
c010012d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100131:	7e 11                	jle    c0100144 <readline+0x86>
            cputchar(c);
c0100133:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100136:	89 04 24             	mov    %eax,(%esp)
c0100139:	e8 af 00 00 00       	call   c01001ed <cputchar>
            i --;
c010013e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0100142:	eb 29                	jmp    c010016d <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c0100144:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100148:	74 06                	je     c0100150 <readline+0x92>
c010014a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010014e:	75 1d                	jne    c010016d <readline+0xaf>
            cputchar(c);
c0100150:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100153:	89 04 24             	mov    %eax,(%esp)
c0100156:	e8 92 00 00 00       	call   c01001ed <cputchar>
            buf[i] = '\0';
c010015b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010015e:	05 80 ca 11 c0       	add    $0xc011ca80,%eax
c0100163:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100166:	b8 80 ca 11 c0       	mov    $0xc011ca80,%eax
c010016b:	eb 05                	jmp    c0100172 <readline+0xb4>
        }
    }
c010016d:	e9 72 ff ff ff       	jmp    c01000e4 <readline+0x26>
}
c0100172:	c9                   	leave  
c0100173:	c3                   	ret    

c0100174 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100174:	55                   	push   %ebp
c0100175:	89 e5                	mov    %esp,%ebp
c0100177:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010017a:	8b 45 08             	mov    0x8(%ebp),%eax
c010017d:	89 04 24             	mov    %eax,(%esp)
c0100180:	e8 0a 13 00 00       	call   c010148f <cons_putc>
    (*cnt) ++;
c0100185:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100188:	8b 00                	mov    (%eax),%eax
c010018a:	8d 50 01             	lea    0x1(%eax),%edx
c010018d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100190:	89 10                	mov    %edx,(%eax)
}
c0100192:	c9                   	leave  
c0100193:	c3                   	ret    

c0100194 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100194:	55                   	push   %ebp
c0100195:	89 e5                	mov    %esp,%ebp
c0100197:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010019a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01001a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01001a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01001a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01001ab:	89 44 24 08          	mov    %eax,0x8(%esp)
c01001af:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01001b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b6:	c7 04 24 74 01 10 c0 	movl   $0xc0100174,(%esp)
c01001bd:	e8 a8 66 00 00       	call   c010686a <vprintfmt>
    return cnt;
c01001c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01001c5:	c9                   	leave  
c01001c6:	c3                   	ret    

c01001c7 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01001c7:	55                   	push   %ebp
c01001c8:	89 e5                	mov    %esp,%ebp
c01001ca:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01001cd:	8d 45 0c             	lea    0xc(%ebp),%eax
c01001d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01001d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01001d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001da:	8b 45 08             	mov    0x8(%ebp),%eax
c01001dd:	89 04 24             	mov    %eax,(%esp)
c01001e0:	e8 af ff ff ff       	call   c0100194 <vcprintf>
c01001e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01001eb:	c9                   	leave  
c01001ec:	c3                   	ret    

c01001ed <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01001ed:	55                   	push   %ebp
c01001ee:	89 e5                	mov    %esp,%ebp
c01001f0:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01001f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01001f6:	89 04 24             	mov    %eax,(%esp)
c01001f9:	e8 91 12 00 00       	call   c010148f <cons_putc>
}
c01001fe:	c9                   	leave  
c01001ff:	c3                   	ret    

c0100200 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100200:	55                   	push   %ebp
c0100201:	89 e5                	mov    %esp,%ebp
c0100203:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100206:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010020d:	eb 13                	jmp    c0100222 <cputs+0x22>
        cputch(c, &cnt);
c010020f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100213:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100216:	89 54 24 04          	mov    %edx,0x4(%esp)
c010021a:	89 04 24             	mov    %eax,(%esp)
c010021d:	e8 52 ff ff ff       	call   c0100174 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c0100222:	8b 45 08             	mov    0x8(%ebp),%eax
c0100225:	8d 50 01             	lea    0x1(%eax),%edx
c0100228:	89 55 08             	mov    %edx,0x8(%ebp)
c010022b:	0f b6 00             	movzbl (%eax),%eax
c010022e:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100231:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100235:	75 d8                	jne    c010020f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100237:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010023a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010023e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100245:	e8 2a ff ff ff       	call   c0100174 <cputch>
    return cnt;
c010024a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010024d:	c9                   	leave  
c010024e:	c3                   	ret    

c010024f <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010024f:	55                   	push   %ebp
c0100250:	89 e5                	mov    %esp,%ebp
c0100252:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100255:	e8 71 12 00 00       	call   c01014cb <cons_getc>
c010025a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010025d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100261:	74 f2                	je     c0100255 <getchar+0x6>
        /* do nothing */;
    return c;
c0100263:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100266:	c9                   	leave  
c0100267:	c3                   	ret    

c0100268 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100268:	55                   	push   %ebp
c0100269:	89 e5                	mov    %esp,%ebp
c010026b:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010026e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100271:	8b 00                	mov    (%eax),%eax
c0100273:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100276:	8b 45 10             	mov    0x10(%ebp),%eax
c0100279:	8b 00                	mov    (%eax),%eax
c010027b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010027e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100285:	e9 d2 00 00 00       	jmp    c010035c <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010028a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010028d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100290:	01 d0                	add    %edx,%eax
c0100292:	89 c2                	mov    %eax,%edx
c0100294:	c1 ea 1f             	shr    $0x1f,%edx
c0100297:	01 d0                	add    %edx,%eax
c0100299:	d1 f8                	sar    %eax
c010029b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010029e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01002a1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01002a4:	eb 04                	jmp    c01002aa <stab_binsearch+0x42>
            m --;
c01002a6:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01002aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ad:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01002b0:	7c 1f                	jl     c01002d1 <stab_binsearch+0x69>
c01002b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b5:	89 d0                	mov    %edx,%eax
c01002b7:	01 c0                	add    %eax,%eax
c01002b9:	01 d0                	add    %edx,%eax
c01002bb:	c1 e0 02             	shl    $0x2,%eax
c01002be:	89 c2                	mov    %eax,%edx
c01002c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c3:	01 d0                	add    %edx,%eax
c01002c5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01002c9:	0f b6 c0             	movzbl %al,%eax
c01002cc:	3b 45 14             	cmp    0x14(%ebp),%eax
c01002cf:	75 d5                	jne    c01002a6 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01002d7:	7d 0b                	jge    c01002e4 <stab_binsearch+0x7c>
            l = true_m + 1;
c01002d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01002dc:	83 c0 01             	add    $0x1,%eax
c01002df:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01002e2:	eb 78                	jmp    c010035c <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c01002e4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01002eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ee:	89 d0                	mov    %edx,%eax
c01002f0:	01 c0                	add    %eax,%eax
c01002f2:	01 d0                	add    %edx,%eax
c01002f4:	c1 e0 02             	shl    $0x2,%eax
c01002f7:	89 c2                	mov    %eax,%edx
c01002f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fc:	01 d0                	add    %edx,%eax
c01002fe:	8b 40 08             	mov    0x8(%eax),%eax
c0100301:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100304:	73 13                	jae    c0100319 <stab_binsearch+0xb1>
            *region_left = m;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010030c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010030e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100311:	83 c0 01             	add    $0x1,%eax
c0100314:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100317:	eb 43                	jmp    c010035c <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100319:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010031c:	89 d0                	mov    %edx,%eax
c010031e:	01 c0                	add    %eax,%eax
c0100320:	01 d0                	add    %edx,%eax
c0100322:	c1 e0 02             	shl    $0x2,%eax
c0100325:	89 c2                	mov    %eax,%edx
c0100327:	8b 45 08             	mov    0x8(%ebp),%eax
c010032a:	01 d0                	add    %edx,%eax
c010032c:	8b 40 08             	mov    0x8(%eax),%eax
c010032f:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100332:	76 16                	jbe    c010034a <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100337:	8d 50 ff             	lea    -0x1(%eax),%edx
c010033a:	8b 45 10             	mov    0x10(%ebp),%eax
c010033d:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010033f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100342:	83 e8 01             	sub    $0x1,%eax
c0100345:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100348:	eb 12                	jmp    c010035c <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010034a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010034d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100350:	89 10                	mov    %edx,(%eax)
            l = m;
c0100352:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100355:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100358:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c010035c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010035f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100362:	0f 8e 22 ff ff ff    	jle    c010028a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0100368:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010036c:	75 0f                	jne    c010037d <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c010036e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100371:	8b 00                	mov    (%eax),%eax
c0100373:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100376:	8b 45 10             	mov    0x10(%ebp),%eax
c0100379:	89 10                	mov    %edx,(%eax)
c010037b:	eb 3f                	jmp    c01003bc <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010037d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100380:	8b 00                	mov    (%eax),%eax
c0100382:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100385:	eb 04                	jmp    c010038b <stab_binsearch+0x123>
c0100387:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010038b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010038e:	8b 00                	mov    (%eax),%eax
c0100390:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100393:	7d 1f                	jge    c01003b4 <stab_binsearch+0x14c>
c0100395:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100398:	89 d0                	mov    %edx,%eax
c010039a:	01 c0                	add    %eax,%eax
c010039c:	01 d0                	add    %edx,%eax
c010039e:	c1 e0 02             	shl    $0x2,%eax
c01003a1:	89 c2                	mov    %eax,%edx
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	01 d0                	add    %edx,%eax
c01003a8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01003ac:	0f b6 c0             	movzbl %al,%eax
c01003af:	3b 45 14             	cmp    0x14(%ebp),%eax
c01003b2:	75 d3                	jne    c0100387 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01003ba:	89 10                	mov    %edx,(%eax)
    }
}
c01003bc:	c9                   	leave  
c01003bd:	c3                   	ret    

c01003be <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01003be:	55                   	push   %ebp
c01003bf:	89 e5                	mov    %esp,%ebp
c01003c1:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01003c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003c7:	c7 00 e4 72 10 c0    	movl   $0xc01072e4,(%eax)
    info->eip_line = 0;
c01003cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003d0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01003d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003da:	c7 40 08 e4 72 10 c0 	movl   $0xc01072e4,0x8(%eax)
    info->eip_fn_namelen = 9;
c01003e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003e4:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01003eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003ee:	8b 55 08             	mov    0x8(%ebp),%edx
c01003f1:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01003f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01003fe:	c7 45 f4 58 8a 10 c0 	movl   $0xc0108a58,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100405:	c7 45 f0 9c 5d 11 c0 	movl   $0xc0115d9c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010040c:	c7 45 ec 9d 5d 11 c0 	movl   $0xc0115d9d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100413:	c7 45 e8 00 94 11 c0 	movl   $0xc0119400,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010041a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010041d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100420:	76 0d                	jbe    c010042f <debuginfo_eip+0x71>
c0100422:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100425:	83 e8 01             	sub    $0x1,%eax
c0100428:	0f b6 00             	movzbl (%eax),%eax
c010042b:	84 c0                	test   %al,%al
c010042d:	74 0a                	je     c0100439 <debuginfo_eip+0x7b>
        return -1;
c010042f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100434:	e9 c0 02 00 00       	jmp    c01006f9 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100439:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100440:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100443:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100446:	29 c2                	sub    %eax,%edx
c0100448:	89 d0                	mov    %edx,%eax
c010044a:	c1 f8 02             	sar    $0x2,%eax
c010044d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100453:	83 e8 01             	sub    $0x1,%eax
c0100456:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100459:	8b 45 08             	mov    0x8(%ebp),%eax
c010045c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100460:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100467:	00 
c0100468:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010046b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010046f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100476:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100479:	89 04 24             	mov    %eax,(%esp)
c010047c:	e8 e7 fd ff ff       	call   c0100268 <stab_binsearch>
    if (lfile == 0)
c0100481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100484:	85 c0                	test   %eax,%eax
c0100486:	75 0a                	jne    c0100492 <debuginfo_eip+0xd4>
        return -1;
c0100488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010048d:	e9 67 02 00 00       	jmp    c01006f9 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100495:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100498:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010049b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010049e:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01004a5:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01004ac:	00 
c01004ad:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01004b0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01004b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004be:	89 04 24             	mov    %eax,(%esp)
c01004c1:	e8 a2 fd ff ff       	call   c0100268 <stab_binsearch>

    if (lfun <= rfun) {
c01004c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01004c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01004cc:	39 c2                	cmp    %eax,%edx
c01004ce:	7f 7c                	jg     c010054c <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01004d3:	89 c2                	mov    %eax,%edx
c01004d5:	89 d0                	mov    %edx,%eax
c01004d7:	01 c0                	add    %eax,%eax
c01004d9:	01 d0                	add    %edx,%eax
c01004db:	c1 e0 02             	shl    $0x2,%eax
c01004de:	89 c2                	mov    %eax,%edx
c01004e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004e3:	01 d0                	add    %edx,%eax
c01004e5:	8b 10                	mov    (%eax),%edx
c01004e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01004ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004ed:	29 c1                	sub    %eax,%ecx
c01004ef:	89 c8                	mov    %ecx,%eax
c01004f1:	39 c2                	cmp    %eax,%edx
c01004f3:	73 22                	jae    c0100517 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c01004f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01004f8:	89 c2                	mov    %eax,%edx
c01004fa:	89 d0                	mov    %edx,%eax
c01004fc:	01 c0                	add    %eax,%eax
c01004fe:	01 d0                	add    %edx,%eax
c0100500:	c1 e0 02             	shl    $0x2,%eax
c0100503:	89 c2                	mov    %eax,%edx
c0100505:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	8b 10                	mov    (%eax),%edx
c010050c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010050f:	01 c2                	add    %eax,%edx
c0100511:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100514:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100517:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010051a:	89 c2                	mov    %eax,%edx
c010051c:	89 d0                	mov    %edx,%eax
c010051e:	01 c0                	add    %eax,%eax
c0100520:	01 d0                	add    %edx,%eax
c0100522:	c1 e0 02             	shl    $0x2,%eax
c0100525:	89 c2                	mov    %eax,%edx
c0100527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010052a:	01 d0                	add    %edx,%eax
c010052c:	8b 50 08             	mov    0x8(%eax),%edx
c010052f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100532:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 40 10             	mov    0x10(%eax),%eax
c010053b:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010053e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100541:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100544:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100547:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010054a:	eb 15                	jmp    c0100561 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010054c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100552:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100555:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100558:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010055e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100561:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100564:	8b 40 08             	mov    0x8(%eax),%eax
c0100567:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010056e:	00 
c010056f:	89 04 24             	mov    %eax,(%esp)
c0100572:	e8 26 6a 00 00       	call   c0106f9d <strfind>
c0100577:	89 c2                	mov    %eax,%edx
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	8b 40 08             	mov    0x8(%eax),%eax
c010057f:	29 c2                	sub    %eax,%edx
c0100581:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100584:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100587:	8b 45 08             	mov    0x8(%ebp),%eax
c010058a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010058e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100595:	00 
c0100596:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100599:	89 44 24 08          	mov    %eax,0x8(%esp)
c010059d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01005a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005a7:	89 04 24             	mov    %eax,(%esp)
c01005aa:	e8 b9 fc ff ff       	call   c0100268 <stab_binsearch>
    if (lline <= rline) {
c01005af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01005b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01005b5:	39 c2                	cmp    %eax,%edx
c01005b7:	7f 24                	jg     c01005dd <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c01005b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01005bc:	89 c2                	mov    %eax,%edx
c01005be:	89 d0                	mov    %edx,%eax
c01005c0:	01 c0                	add    %eax,%eax
c01005c2:	01 d0                	add    %edx,%eax
c01005c4:	c1 e0 02             	shl    $0x2,%eax
c01005c7:	89 c2                	mov    %eax,%edx
c01005c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005cc:	01 d0                	add    %edx,%eax
c01005ce:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01005d2:	0f b7 d0             	movzwl %ax,%edx
c01005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d8:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01005db:	eb 13                	jmp    c01005f0 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c01005dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005e2:	e9 12 01 00 00       	jmp    c01006f9 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01005e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01005ea:	83 e8 01             	sub    $0x1,%eax
c01005ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01005f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01005f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005f6:	39 c2                	cmp    %eax,%edx
c01005f8:	7c 56                	jl     c0100650 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c01005fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01005fd:	89 c2                	mov    %eax,%edx
c01005ff:	89 d0                	mov    %edx,%eax
c0100601:	01 c0                	add    %eax,%eax
c0100603:	01 d0                	add    %edx,%eax
c0100605:	c1 e0 02             	shl    $0x2,%eax
c0100608:	89 c2                	mov    %eax,%edx
c010060a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010060d:	01 d0                	add    %edx,%eax
c010060f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100613:	3c 84                	cmp    $0x84,%al
c0100615:	74 39                	je     c0100650 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100617:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010061a:	89 c2                	mov    %eax,%edx
c010061c:	89 d0                	mov    %edx,%eax
c010061e:	01 c0                	add    %eax,%eax
c0100620:	01 d0                	add    %edx,%eax
c0100622:	c1 e0 02             	shl    $0x2,%eax
c0100625:	89 c2                	mov    %eax,%edx
c0100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010062a:	01 d0                	add    %edx,%eax
c010062c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100630:	3c 64                	cmp    $0x64,%al
c0100632:	75 b3                	jne    c01005e7 <debuginfo_eip+0x229>
c0100634:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100637:	89 c2                	mov    %eax,%edx
c0100639:	89 d0                	mov    %edx,%eax
c010063b:	01 c0                	add    %eax,%eax
c010063d:	01 d0                	add    %edx,%eax
c010063f:	c1 e0 02             	shl    $0x2,%eax
c0100642:	89 c2                	mov    %eax,%edx
c0100644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100647:	01 d0                	add    %edx,%eax
c0100649:	8b 40 08             	mov    0x8(%eax),%eax
c010064c:	85 c0                	test   %eax,%eax
c010064e:	74 97                	je     c01005e7 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100650:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100656:	39 c2                	cmp    %eax,%edx
c0100658:	7c 46                	jl     c01006a0 <debuginfo_eip+0x2e2>
c010065a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010065d:	89 c2                	mov    %eax,%edx
c010065f:	89 d0                	mov    %edx,%eax
c0100661:	01 c0                	add    %eax,%eax
c0100663:	01 d0                	add    %edx,%eax
c0100665:	c1 e0 02             	shl    $0x2,%eax
c0100668:	89 c2                	mov    %eax,%edx
c010066a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066d:	01 d0                	add    %edx,%eax
c010066f:	8b 10                	mov    (%eax),%edx
c0100671:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100674:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100677:	29 c1                	sub    %eax,%ecx
c0100679:	89 c8                	mov    %ecx,%eax
c010067b:	39 c2                	cmp    %eax,%edx
c010067d:	73 21                	jae    c01006a0 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010067f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100682:	89 c2                	mov    %eax,%edx
c0100684:	89 d0                	mov    %edx,%eax
c0100686:	01 c0                	add    %eax,%eax
c0100688:	01 d0                	add    %edx,%eax
c010068a:	c1 e0 02             	shl    $0x2,%eax
c010068d:	89 c2                	mov    %eax,%edx
c010068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100692:	01 d0                	add    %edx,%eax
c0100694:	8b 10                	mov    (%eax),%edx
c0100696:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100699:	01 c2                	add    %eax,%edx
c010069b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01006a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006a6:	39 c2                	cmp    %eax,%edx
c01006a8:	7d 4a                	jge    c01006f4 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c01006aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006ad:	83 c0 01             	add    $0x1,%eax
c01006b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01006b3:	eb 18                	jmp    c01006cd <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b8:	8b 40 14             	mov    0x14(%eax),%eax
c01006bb:	8d 50 01             	lea    0x1(%eax),%edx
c01006be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c1:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01006c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01006c7:	83 c0 01             	add    $0x1,%eax
c01006ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01006cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c01006d3:	39 c2                	cmp    %eax,%edx
c01006d5:	7d 1d                	jge    c01006f4 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01006d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01006da:	89 c2                	mov    %eax,%edx
c01006dc:	89 d0                	mov    %edx,%eax
c01006de:	01 c0                	add    %eax,%eax
c01006e0:	01 d0                	add    %edx,%eax
c01006e2:	c1 e0 02             	shl    $0x2,%eax
c01006e5:	89 c2                	mov    %eax,%edx
c01006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ea:	01 d0                	add    %edx,%eax
c01006ec:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01006f0:	3c a0                	cmp    $0xa0,%al
c01006f2:	74 c1                	je     c01006b5 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c01006f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01006f9:	c9                   	leave  
c01006fa:	c3                   	ret    

c01006fb <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c01006fb:	55                   	push   %ebp
c01006fc:	89 e5                	mov    %esp,%ebp
c01006fe:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100701:	c7 04 24 ee 72 10 c0 	movl   $0xc01072ee,(%esp)
c0100708:	e8 ba fa ff ff       	call   c01001c7 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010070d:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100714:	c0 
c0100715:	c7 04 24 07 73 10 c0 	movl   $0xc0107307,(%esp)
c010071c:	e8 a6 fa ff ff       	call   c01001c7 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100721:	c7 44 24 04 b2 72 10 	movl   $0xc01072b2,0x4(%esp)
c0100728:	c0 
c0100729:	c7 04 24 1f 73 10 c0 	movl   $0xc010731f,(%esp)
c0100730:	e8 92 fa ff ff       	call   c01001c7 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100735:	c7 44 24 04 68 ca 11 	movl   $0xc011ca68,0x4(%esp)
c010073c:	c0 
c010073d:	c7 04 24 37 73 10 c0 	movl   $0xc0107337,(%esp)
c0100744:	e8 7e fa ff ff       	call   c01001c7 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100749:	c7 44 24 04 d8 d9 11 	movl   $0xc011d9d8,0x4(%esp)
c0100750:	c0 
c0100751:	c7 04 24 4f 73 10 c0 	movl   $0xc010734f,(%esp)
c0100758:	e8 6a fa ff ff       	call   c01001c7 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010075d:	b8 d8 d9 11 c0       	mov    $0xc011d9d8,%eax
c0100762:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100768:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c010076d:	29 c2                	sub    %eax,%edx
c010076f:	89 d0                	mov    %edx,%eax
c0100771:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100777:	85 c0                	test   %eax,%eax
c0100779:	0f 48 c2             	cmovs  %edx,%eax
c010077c:	c1 f8 0a             	sar    $0xa,%eax
c010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100783:	c7 04 24 68 73 10 c0 	movl   $0xc0107368,(%esp)
c010078a:	e8 38 fa ff ff       	call   c01001c7 <cprintf>
}
c010078f:	c9                   	leave  
c0100790:	c3                   	ret    

c0100791 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100791:	55                   	push   %ebp
c0100792:	89 e5                	mov    %esp,%ebp
c0100794:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010079a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010079d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01007a4:	89 04 24             	mov    %eax,(%esp)
c01007a7:	e8 12 fc ff ff       	call   c01003be <debuginfo_eip>
c01007ac:	85 c0                	test   %eax,%eax
c01007ae:	74 15                	je     c01007c5 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01007b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007b7:	c7 04 24 92 73 10 c0 	movl   $0xc0107392,(%esp)
c01007be:	e8 04 fa ff ff       	call   c01001c7 <cprintf>
c01007c3:	eb 6d                	jmp    c0100832 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01007c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01007cc:	eb 1c                	jmp    c01007ea <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01007ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01007d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d4:	01 d0                	add    %edx,%eax
c01007d6:	0f b6 00             	movzbl (%eax),%eax
c01007d9:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01007df:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01007e2:	01 ca                	add    %ecx,%edx
c01007e4:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01007e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01007ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01007f0:	7f dc                	jg     c01007ce <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c01007f2:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c01007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fb:	01 d0                	add    %edx,%eax
c01007fd:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100800:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100803:	8b 55 08             	mov    0x8(%ebp),%edx
c0100806:	89 d1                	mov    %edx,%ecx
c0100808:	29 c1                	sub    %eax,%ecx
c010080a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010080d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100810:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100814:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010081a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010081e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100822:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100826:	c7 04 24 ae 73 10 c0 	movl   $0xc01073ae,(%esp)
c010082d:	e8 95 f9 ff ff       	call   c01001c7 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100832:	c9                   	leave  
c0100833:	c3                   	ret    

c0100834 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100834:	55                   	push   %ebp
c0100835:	89 e5                	mov    %esp,%ebp
c0100837:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c010083a:	8b 45 04             	mov    0x4(%ebp),%eax
c010083d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100840:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100843:	c9                   	leave  
c0100844:	c3                   	ret    

c0100845 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100845:	55                   	push   %ebp
c0100846:	89 e5                	mov    %esp,%ebp
c0100848:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c010084b:	89 e8                	mov    %ebp,%eax
c010084d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100850:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp, eip;
    int i, j;
    ebp = read_ebp();
c0100853:	89 45 f4             	mov    %eax,-0xc(%ebp)
    eip = read_eip();
c0100856:	e8 d9 ff ff ff       	call   c0100834 <read_eip>
c010085b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; i < STACKFRAME_DEPTH; i++) {
c010085e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100865:	e9 9a 00 00 00       	jmp    c0100904 <print_stackframe+0xbf>
        uint32_t *start = (uint32_t *)ebp + 2;
c010086a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086d:	83 c0 08             	add    $0x8,%eax
c0100870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100873:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100876:	89 44 24 08          	mov    %eax,0x8(%esp)
c010087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100881:	c7 04 24 c0 73 10 c0 	movl   $0xc01073c0,(%esp)
c0100888:	e8 3a f9 ff ff       	call   c01001c7 <cprintf>
        for (j = 0; j < 4; j++) {
c010088d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100894:	eb 37                	jmp    c01008cd <print_stackframe+0x88>
            cprintf("0x%08x", *(start + j));
c0100896:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100899:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01008a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a3:	01 d0                	add    %edx,%eax
c01008a5:	8b 00                	mov    (%eax),%eax
c01008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008ab:	c7 04 24 dc 73 10 c0 	movl   $0xc01073dc,(%esp)
c01008b2:	e8 10 f9 ff ff       	call   c01001c7 <cprintf>
            if (j != 3)
c01008b7:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c01008bb:	74 0c                	je     c01008c9 <print_stackframe+0x84>
                cprintf(" ");
c01008bd:	c7 04 24 e3 73 10 c0 	movl   $0xc01073e3,(%esp)
c01008c4:	e8 fe f8 ff ff       	call   c01001c7 <cprintf>
    ebp = read_ebp();
    eip = read_eip();
    for (i = 0; i < STACKFRAME_DEPTH; i++) {
        uint32_t *start = (uint32_t *)ebp + 2;
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        for (j = 0; j < 4; j++) {
c01008c9:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c01008cd:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c01008d1:	7e c3                	jle    c0100896 <print_stackframe+0x51>
            cprintf("0x%08x", *(start + j));
            if (j != 3)
                cprintf(" ");
        }
        cprintf("\n");
c01008d3:	c7 04 24 e5 73 10 c0 	movl   $0xc01073e5,(%esp)
c01008da:	e8 e8 f8 ff ff       	call   c01001c7 <cprintf>
        print_debuginfo(eip - 1);
c01008df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01008e2:	83 e8 01             	sub    $0x1,%eax
c01008e5:	89 04 24             	mov    %eax,(%esp)
c01008e8:	e8 a4 fe ff ff       	call   c0100791 <print_debuginfo>
        ebp = *((uint32_t *)ebp);
c01008ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f0:	8b 00                	mov    (%eax),%eax
c01008f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        eip = *((uint32_t *)ebp + 1);
c01008f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f8:	83 c0 04             	add    $0x4,%eax
c01008fb:	8b 00                	mov    (%eax),%eax
c01008fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      */
    uint32_t ebp, eip;
    int i, j;
    ebp = read_ebp();
    eip = read_eip();
    for (i = 0; i < STACKFRAME_DEPTH; i++) {
c0100900:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100904:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100908:	0f 8e 5c ff ff ff    	jle    c010086a <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        ebp = *((uint32_t *)ebp);
        eip = *((uint32_t *)ebp + 1);
    }
}
c010090e:	c9                   	leave  
c010090f:	c3                   	ret    

c0100910 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100910:	55                   	push   %ebp
c0100911:	89 e5                	mov    %esp,%ebp
c0100913:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100916:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c010091d:	eb 0c                	jmp    c010092b <parse+0x1b>
            *buf ++ = '\0';
c010091f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100922:	8d 50 01             	lea    0x1(%eax),%edx
c0100925:	89 55 08             	mov    %edx,0x8(%ebp)
c0100928:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c010092b:	8b 45 08             	mov    0x8(%ebp),%eax
c010092e:	0f b6 00             	movzbl (%eax),%eax
c0100931:	84 c0                	test   %al,%al
c0100933:	74 1d                	je     c0100952 <parse+0x42>
c0100935:	8b 45 08             	mov    0x8(%ebp),%eax
c0100938:	0f b6 00             	movzbl (%eax),%eax
c010093b:	0f be c0             	movsbl %al,%eax
c010093e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100942:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0100949:	e8 1c 66 00 00       	call   c0106f6a <strchr>
c010094e:	85 c0                	test   %eax,%eax
c0100950:	75 cd                	jne    c010091f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100952:	8b 45 08             	mov    0x8(%ebp),%eax
c0100955:	0f b6 00             	movzbl (%eax),%eax
c0100958:	84 c0                	test   %al,%al
c010095a:	75 02                	jne    c010095e <parse+0x4e>
            break;
c010095c:	eb 67                	jmp    c01009c5 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c010095e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100962:	75 14                	jne    c0100978 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100964:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c010096b:	00 
c010096c:	c7 04 24 6d 74 10 c0 	movl   $0xc010746d,(%esp)
c0100973:	e8 4f f8 ff ff       	call   c01001c7 <cprintf>
        }
        argv[argc ++] = buf;
c0100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097b:	8d 50 01             	lea    0x1(%eax),%edx
c010097e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100981:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100988:	8b 45 0c             	mov    0xc(%ebp),%eax
c010098b:	01 c2                	add    %eax,%edx
c010098d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100990:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100992:	eb 04                	jmp    c0100998 <parse+0x88>
            buf ++;
c0100994:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100998:	8b 45 08             	mov    0x8(%ebp),%eax
c010099b:	0f b6 00             	movzbl (%eax),%eax
c010099e:	84 c0                	test   %al,%al
c01009a0:	74 1d                	je     c01009bf <parse+0xaf>
c01009a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01009a5:	0f b6 00             	movzbl (%eax),%eax
c01009a8:	0f be c0             	movsbl %al,%eax
c01009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009af:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01009b6:	e8 af 65 00 00       	call   c0106f6a <strchr>
c01009bb:	85 c0                	test   %eax,%eax
c01009bd:	74 d5                	je     c0100994 <parse+0x84>
            buf ++;
        }
    }
c01009bf:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009c0:	e9 66 ff ff ff       	jmp    c010092b <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c01009c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01009c8:	c9                   	leave  
c01009c9:	c3                   	ret    

c01009ca <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c01009ca:	55                   	push   %ebp
c01009cb:	89 e5                	mov    %esp,%ebp
c01009cd:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c01009d0:	8d 45 b0             	lea    -0x50(%ebp),%eax
c01009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01009da:	89 04 24             	mov    %eax,(%esp)
c01009dd:	e8 2e ff ff ff       	call   c0100910 <parse>
c01009e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c01009e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01009e9:	75 0a                	jne    c01009f5 <runcmd+0x2b>
        return 0;
c01009eb:	b8 00 00 00 00       	mov    $0x0,%eax
c01009f0:	e9 85 00 00 00       	jmp    c0100a7a <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01009f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009fc:	eb 5c                	jmp    c0100a5a <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c01009fe:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a04:	89 d0                	mov    %edx,%eax
c0100a06:	01 c0                	add    %eax,%eax
c0100a08:	01 d0                	add    %edx,%eax
c0100a0a:	c1 e0 02             	shl    $0x2,%eax
c0100a0d:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100a12:	8b 00                	mov    (%eax),%eax
c0100a14:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100a18:	89 04 24             	mov    %eax,(%esp)
c0100a1b:	e8 ab 64 00 00       	call   c0106ecb <strcmp>
c0100a20:	85 c0                	test   %eax,%eax
c0100a22:	75 32                	jne    c0100a56 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a27:	89 d0                	mov    %edx,%eax
c0100a29:	01 c0                	add    %eax,%eax
c0100a2b:	01 d0                	add    %edx,%eax
c0100a2d:	c1 e0 02             	shl    $0x2,%eax
c0100a30:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100a35:	8b 40 08             	mov    0x8(%eax),%eax
c0100a38:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100a3b:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100a41:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a45:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100a48:	83 c2 04             	add    $0x4,%edx
c0100a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100a4f:	89 0c 24             	mov    %ecx,(%esp)
c0100a52:	ff d0                	call   *%eax
c0100a54:	eb 24                	jmp    c0100a7a <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100a56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5d:	83 f8 02             	cmp    $0x2,%eax
c0100a60:	76 9c                	jbe    c01009fe <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100a62:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100a65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a69:	c7 04 24 8b 74 10 c0 	movl   $0xc010748b,(%esp)
c0100a70:	e8 52 f7 ff ff       	call   c01001c7 <cprintf>
    return 0;
c0100a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a7a:	c9                   	leave  
c0100a7b:	c3                   	ret    

c0100a7c <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100a7c:	55                   	push   %ebp
c0100a7d:	89 e5                	mov    %esp,%ebp
c0100a7f:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100a82:	c7 04 24 a4 74 10 c0 	movl   $0xc01074a4,(%esp)
c0100a89:	e8 39 f7 ff ff       	call   c01001c7 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100a8e:	c7 04 24 cc 74 10 c0 	movl   $0xc01074cc,(%esp)
c0100a95:	e8 2d f7 ff ff       	call   c01001c7 <cprintf>

    if (tf != NULL) {
c0100a9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100a9e:	74 0b                	je     c0100aab <kmonitor+0x2f>
        print_trapframe(tf);
c0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa3:	89 04 24             	mov    %eax,(%esp)
c0100aa6:	e8 7e 0e 00 00       	call   c0101929 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100aab:	c7 04 24 f1 74 10 c0 	movl   $0xc01074f1,(%esp)
c0100ab2:	e8 07 f6 ff ff       	call   c01000be <readline>
c0100ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100abe:	74 18                	je     c0100ad8 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aca:	89 04 24             	mov    %eax,(%esp)
c0100acd:	e8 f8 fe ff ff       	call   c01009ca <runcmd>
c0100ad2:	85 c0                	test   %eax,%eax
c0100ad4:	79 02                	jns    c0100ad8 <kmonitor+0x5c>
                break;
c0100ad6:	eb 02                	jmp    c0100ada <kmonitor+0x5e>
            }
        }
    }
c0100ad8:	eb d1                	jmp    c0100aab <kmonitor+0x2f>
}
c0100ada:	c9                   	leave  
c0100adb:	c3                   	ret    

c0100adc <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100adc:	55                   	push   %ebp
c0100add:	89 e5                	mov    %esp,%ebp
c0100adf:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ae9:	eb 3f                	jmp    c0100b2a <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100aee:	89 d0                	mov    %edx,%eax
c0100af0:	01 c0                	add    %eax,%eax
c0100af2:	01 d0                	add    %edx,%eax
c0100af4:	c1 e0 02             	shl    $0x2,%eax
c0100af7:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100afc:	8b 48 04             	mov    0x4(%eax),%ecx
c0100aff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b02:	89 d0                	mov    %edx,%eax
c0100b04:	01 c0                	add    %eax,%eax
c0100b06:	01 d0                	add    %edx,%eax
c0100b08:	c1 e0 02             	shl    $0x2,%eax
c0100b0b:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100b10:	8b 00                	mov    (%eax),%eax
c0100b12:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100b16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b1a:	c7 04 24 f5 74 10 c0 	movl   $0xc01074f5,(%esp)
c0100b21:	e8 a1 f6 ff ff       	call   c01001c7 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b2d:	83 f8 02             	cmp    $0x2,%eax
c0100b30:	76 b9                	jbe    c0100aeb <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b37:	c9                   	leave  
c0100b38:	c3                   	ret    

c0100b39 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100b39:	55                   	push   %ebp
c0100b3a:	89 e5                	mov    %esp,%ebp
c0100b3c:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100b3f:	e8 b7 fb ff ff       	call   c01006fb <print_kerninfo>
    return 0;
c0100b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b49:	c9                   	leave  
c0100b4a:	c3                   	ret    

c0100b4b <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100b4b:	55                   	push   %ebp
c0100b4c:	89 e5                	mov    %esp,%ebp
c0100b4e:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100b51:	e8 ef fc ff ff       	call   c0100845 <print_stackframe>
    return 0;
c0100b56:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b5b:	c9                   	leave  
c0100b5c:	c3                   	ret    

c0100b5d <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100b5d:	55                   	push   %ebp
c0100b5e:	89 e5                	mov    %esp,%ebp
c0100b60:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100b63:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0100b68:	85 c0                	test   %eax,%eax
c0100b6a:	74 02                	je     c0100b6e <__panic+0x11>
        goto panic_dead;
c0100b6c:	eb 48                	jmp    c0100bb6 <__panic+0x59>
    }
    is_panic = 1;
c0100b6e:	c7 05 80 ce 11 c0 01 	movl   $0x1,0xc011ce80
c0100b75:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100b78:	8d 45 14             	lea    0x14(%ebp),%eax
c0100b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b81:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b8c:	c7 04 24 fe 74 10 c0 	movl   $0xc01074fe,(%esp)
c0100b93:	e8 2f f6 ff ff       	call   c01001c7 <cprintf>
    vcprintf(fmt, ap);
c0100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100ba2:	89 04 24             	mov    %eax,(%esp)
c0100ba5:	e8 ea f5 ff ff       	call   c0100194 <vcprintf>
    cprintf("\n");
c0100baa:	c7 04 24 1a 75 10 c0 	movl   $0xc010751a,(%esp)
c0100bb1:	e8 11 f6 ff ff       	call   c01001c7 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100bb6:	e8 85 09 00 00       	call   c0101540 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100bbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100bc2:	e8 b5 fe ff ff       	call   c0100a7c <kmonitor>
    }
c0100bc7:	eb f2                	jmp    c0100bbb <__panic+0x5e>

c0100bc9 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100bc9:	55                   	push   %ebp
c0100bca:	89 e5                	mov    %esp,%ebp
c0100bcc:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100bcf:	8d 45 14             	lea    0x14(%ebp),%eax
c0100bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bd8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be3:	c7 04 24 1c 75 10 c0 	movl   $0xc010751c,(%esp)
c0100bea:	e8 d8 f5 ff ff       	call   c01001c7 <cprintf>
    vcprintf(fmt, ap);
c0100bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf6:	8b 45 10             	mov    0x10(%ebp),%eax
c0100bf9:	89 04 24             	mov    %eax,(%esp)
c0100bfc:	e8 93 f5 ff ff       	call   c0100194 <vcprintf>
    cprintf("\n");
c0100c01:	c7 04 24 1a 75 10 c0 	movl   $0xc010751a,(%esp)
c0100c08:	e8 ba f5 ff ff       	call   c01001c7 <cprintf>
    va_end(ap);
}
c0100c0d:	c9                   	leave  
c0100c0e:	c3                   	ret    

c0100c0f <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100c0f:	55                   	push   %ebp
c0100c10:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100c12:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
}
c0100c17:	5d                   	pop    %ebp
c0100c18:	c3                   	ret    

c0100c19 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100c19:	55                   	push   %ebp
c0100c1a:	89 e5                	mov    %esp,%ebp
c0100c1c:	83 ec 28             	sub    $0x28,%esp
c0100c1f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100c25:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100c29:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100c2d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100c31:	ee                   	out    %al,(%dx)
c0100c32:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100c38:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100c3c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100c40:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100c44:	ee                   	out    %al,(%dx)
c0100c45:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100c4b:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100c4f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100c53:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100c57:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100c58:	c7 05 b4 d9 11 c0 00 	movl   $0x0,0xc011d9b4
c0100c5f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100c62:	c7 04 24 3a 75 10 c0 	movl   $0xc010753a,(%esp)
c0100c69:	e8 59 f5 ff ff       	call   c01001c7 <cprintf>
    pic_enable(IRQ_TIMER);
c0100c6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100c75:	e8 24 09 00 00       	call   c010159e <pic_enable>
}
c0100c7a:	c9                   	leave  
c0100c7b:	c3                   	ret    

c0100c7c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100c7c:	55                   	push   %ebp
c0100c7d:	89 e5                	mov    %esp,%ebp
c0100c7f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100c82:	9c                   	pushf  
c0100c83:	58                   	pop    %eax
c0100c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100c8a:	25 00 02 00 00       	and    $0x200,%eax
c0100c8f:	85 c0                	test   %eax,%eax
c0100c91:	74 0c                	je     c0100c9f <__intr_save+0x23>
        intr_disable();
c0100c93:	e8 a8 08 00 00       	call   c0101540 <intr_disable>
        return 1;
c0100c98:	b8 01 00 00 00       	mov    $0x1,%eax
c0100c9d:	eb 05                	jmp    c0100ca4 <__intr_save+0x28>
    }
    return 0;
c0100c9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca4:	c9                   	leave  
c0100ca5:	c3                   	ret    

c0100ca6 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100ca6:	55                   	push   %ebp
c0100ca7:	89 e5                	mov    %esp,%ebp
c0100ca9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100cac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cb0:	74 05                	je     c0100cb7 <__intr_restore+0x11>
        intr_enable();
c0100cb2:	e8 83 08 00 00       	call   c010153a <intr_enable>
    }
}
c0100cb7:	c9                   	leave  
c0100cb8:	c3                   	ret    

c0100cb9 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100cb9:	55                   	push   %ebp
c0100cba:	89 e5                	mov    %esp,%ebp
c0100cbc:	83 ec 10             	sub    $0x10,%esp
c0100cbf:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100cc5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100cc9:	89 c2                	mov    %eax,%edx
c0100ccb:	ec                   	in     (%dx),%al
c0100ccc:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100ccf:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100cd5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100cd9:	89 c2                	mov    %eax,%edx
c0100cdb:	ec                   	in     (%dx),%al
c0100cdc:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100cdf:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ce5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ce9:	89 c2                	mov    %eax,%edx
c0100ceb:	ec                   	in     (%dx),%al
c0100cec:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100cef:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100cf5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100cf9:	89 c2                	mov    %eax,%edx
c0100cfb:	ec                   	in     (%dx),%al
c0100cfc:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100cff:	c9                   	leave  
c0100d00:	c3                   	ret    

c0100d01 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100d01:	55                   	push   %ebp
c0100d02:	89 e5                	mov    %esp,%ebp
c0100d04:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100d07:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d11:	0f b7 00             	movzwl (%eax),%eax
c0100d14:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100d18:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d1b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100d20:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d23:	0f b7 00             	movzwl (%eax),%eax
c0100d26:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100d2a:	74 12                	je     c0100d3e <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100d2c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100d33:	66 c7 05 a6 ce 11 c0 	movw   $0x3b4,0xc011cea6
c0100d3a:	b4 03 
c0100d3c:	eb 13                	jmp    c0100d51 <cga_init+0x50>
    } else {
        *cp = was;
c0100d3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d41:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100d45:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100d48:	66 c7 05 a6 ce 11 c0 	movw   $0x3d4,0xc011cea6
c0100d4f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100d51:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c0100d58:	0f b7 c0             	movzwl %ax,%eax
c0100d5b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100d5f:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d63:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100d67:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100d6b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100d6c:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c0100d73:	83 c0 01             	add    $0x1,%eax
c0100d76:	0f b7 c0             	movzwl %ax,%eax
c0100d79:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100d7d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100d81:	89 c2                	mov    %eax,%edx
c0100d83:	ec                   	in     (%dx),%al
c0100d84:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100d87:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d8b:	0f b6 c0             	movzbl %al,%eax
c0100d8e:	c1 e0 08             	shl    $0x8,%eax
c0100d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100d94:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c0100d9b:	0f b7 c0             	movzwl %ax,%eax
c0100d9e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100da2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100da6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100daa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100dae:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100daf:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c0100db6:	83 c0 01             	add    $0x1,%eax
c0100db9:	0f b7 c0             	movzwl %ax,%eax
c0100dbc:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100dc0:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100dc4:	89 c2                	mov    %eax,%edx
c0100dc6:	ec                   	in     (%dx),%al
c0100dc7:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100dca:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100dce:	0f b6 c0             	movzbl %al,%eax
c0100dd1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100dd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd7:	a3 a0 ce 11 c0       	mov    %eax,0xc011cea0
    crt_pos = pos;
c0100ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ddf:	66 a3 a4 ce 11 c0    	mov    %ax,0xc011cea4
}
c0100de5:	c9                   	leave  
c0100de6:	c3                   	ret    

c0100de7 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100de7:	55                   	push   %ebp
c0100de8:	89 e5                	mov    %esp,%ebp
c0100dea:	83 ec 48             	sub    $0x48,%esp
c0100ded:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100df3:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100df7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dfb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dff:	ee                   	out    %al,(%dx)
c0100e00:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100e06:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100e0a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e0e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e12:	ee                   	out    %al,(%dx)
c0100e13:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100e19:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100e1d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e21:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e25:	ee                   	out    %al,(%dx)
c0100e26:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100e2c:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100e30:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100e34:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e38:	ee                   	out    %al,(%dx)
c0100e39:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100e3f:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100e43:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100e47:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100e4b:	ee                   	out    %al,(%dx)
c0100e4c:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100e52:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100e56:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100e5a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100e5e:	ee                   	out    %al,(%dx)
c0100e5f:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100e65:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100e69:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100e6d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100e71:	ee                   	out    %al,(%dx)
c0100e72:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e78:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100e7c:	89 c2                	mov    %eax,%edx
c0100e7e:	ec                   	in     (%dx),%al
c0100e7f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100e82:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100e86:	3c ff                	cmp    $0xff,%al
c0100e88:	0f 95 c0             	setne  %al
c0100e8b:	0f b6 c0             	movzbl %al,%eax
c0100e8e:	a3 a8 ce 11 c0       	mov    %eax,0xc011cea8
c0100e93:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e99:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0100e9d:	89 c2                	mov    %eax,%edx
c0100e9f:	ec                   	in     (%dx),%al
c0100ea0:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0100ea3:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0100ea9:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100ead:	89 c2                	mov    %eax,%edx
c0100eaf:	ec                   	in     (%dx),%al
c0100eb0:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0100eb3:	a1 a8 ce 11 c0       	mov    0xc011cea8,%eax
c0100eb8:	85 c0                	test   %eax,%eax
c0100eba:	74 0c                	je     c0100ec8 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0100ebc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0100ec3:	e8 d6 06 00 00       	call   c010159e <pic_enable>
    }
}
c0100ec8:	c9                   	leave  
c0100ec9:	c3                   	ret    

c0100eca <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0100eca:	55                   	push   %ebp
c0100ecb:	89 e5                	mov    %esp,%ebp
c0100ecd:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100ed0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0100ed7:	eb 09                	jmp    c0100ee2 <lpt_putc_sub+0x18>
        delay();
c0100ed9:	e8 db fd ff ff       	call   c0100cb9 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100ede:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0100ee2:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0100ee8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100eec:	89 c2                	mov    %eax,%edx
c0100eee:	ec                   	in     (%dx),%al
c0100eef:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100ef2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100ef6:	84 c0                	test   %al,%al
c0100ef8:	78 09                	js     c0100f03 <lpt_putc_sub+0x39>
c0100efa:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0100f01:	7e d6                	jle    c0100ed9 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0100f03:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f06:	0f b6 c0             	movzbl %al,%eax
c0100f09:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0100f0f:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f12:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f16:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f1a:	ee                   	out    %al,(%dx)
c0100f1b:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0100f21:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0100f25:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f2d:	ee                   	out    %al,(%dx)
c0100f2e:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0100f34:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0100f38:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f40:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0100f41:	c9                   	leave  
c0100f42:	c3                   	ret    

c0100f43 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0100f43:	55                   	push   %ebp
c0100f44:	89 e5                	mov    %esp,%ebp
c0100f46:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0100f49:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0100f4d:	74 0d                	je     c0100f5c <lpt_putc+0x19>
        lpt_putc_sub(c);
c0100f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f52:	89 04 24             	mov    %eax,(%esp)
c0100f55:	e8 70 ff ff ff       	call   c0100eca <lpt_putc_sub>
c0100f5a:	eb 24                	jmp    c0100f80 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0100f5c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0100f63:	e8 62 ff ff ff       	call   c0100eca <lpt_putc_sub>
        lpt_putc_sub(' ');
c0100f68:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0100f6f:	e8 56 ff ff ff       	call   c0100eca <lpt_putc_sub>
        lpt_putc_sub('\b');
c0100f74:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0100f7b:	e8 4a ff ff ff       	call   c0100eca <lpt_putc_sub>
    }
}
c0100f80:	c9                   	leave  
c0100f81:	c3                   	ret    

c0100f82 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0100f82:	55                   	push   %ebp
c0100f83:	89 e5                	mov    %esp,%ebp
c0100f85:	53                   	push   %ebx
c0100f86:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0100f89:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f8c:	b0 00                	mov    $0x0,%al
c0100f8e:	85 c0                	test   %eax,%eax
c0100f90:	75 07                	jne    c0100f99 <cga_putc+0x17>
        c |= 0x0700;
c0100f92:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0100f99:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f9c:	0f b6 c0             	movzbl %al,%eax
c0100f9f:	83 f8 0a             	cmp    $0xa,%eax
c0100fa2:	74 4c                	je     c0100ff0 <cga_putc+0x6e>
c0100fa4:	83 f8 0d             	cmp    $0xd,%eax
c0100fa7:	74 57                	je     c0101000 <cga_putc+0x7e>
c0100fa9:	83 f8 08             	cmp    $0x8,%eax
c0100fac:	0f 85 88 00 00 00    	jne    c010103a <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0100fb2:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0100fb9:	66 85 c0             	test   %ax,%ax
c0100fbc:	74 30                	je     c0100fee <cga_putc+0x6c>
            crt_pos --;
c0100fbe:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0100fc5:	83 e8 01             	sub    $0x1,%eax
c0100fc8:	66 a3 a4 ce 11 c0    	mov    %ax,0xc011cea4
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0100fce:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0100fd3:	0f b7 15 a4 ce 11 c0 	movzwl 0xc011cea4,%edx
c0100fda:	0f b7 d2             	movzwl %dx,%edx
c0100fdd:	01 d2                	add    %edx,%edx
c0100fdf:	01 c2                	add    %eax,%edx
c0100fe1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fe4:	b0 00                	mov    $0x0,%al
c0100fe6:	83 c8 20             	or     $0x20,%eax
c0100fe9:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0100fec:	eb 72                	jmp    c0101060 <cga_putc+0xde>
c0100fee:	eb 70                	jmp    c0101060 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0100ff0:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0100ff7:	83 c0 50             	add    $0x50,%eax
c0100ffa:	66 a3 a4 ce 11 c0    	mov    %ax,0xc011cea4
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101000:	0f b7 1d a4 ce 11 c0 	movzwl 0xc011cea4,%ebx
c0101007:	0f b7 0d a4 ce 11 c0 	movzwl 0xc011cea4,%ecx
c010100e:	0f b7 c1             	movzwl %cx,%eax
c0101011:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101017:	c1 e8 10             	shr    $0x10,%eax
c010101a:	89 c2                	mov    %eax,%edx
c010101c:	66 c1 ea 06          	shr    $0x6,%dx
c0101020:	89 d0                	mov    %edx,%eax
c0101022:	c1 e0 02             	shl    $0x2,%eax
c0101025:	01 d0                	add    %edx,%eax
c0101027:	c1 e0 04             	shl    $0x4,%eax
c010102a:	29 c1                	sub    %eax,%ecx
c010102c:	89 ca                	mov    %ecx,%edx
c010102e:	89 d8                	mov    %ebx,%eax
c0101030:	29 d0                	sub    %edx,%eax
c0101032:	66 a3 a4 ce 11 c0    	mov    %ax,0xc011cea4
        break;
c0101038:	eb 26                	jmp    c0101060 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010103a:	8b 0d a0 ce 11 c0    	mov    0xc011cea0,%ecx
c0101040:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0101047:	8d 50 01             	lea    0x1(%eax),%edx
c010104a:	66 89 15 a4 ce 11 c0 	mov    %dx,0xc011cea4
c0101051:	0f b7 c0             	movzwl %ax,%eax
c0101054:	01 c0                	add    %eax,%eax
c0101056:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101059:	8b 45 08             	mov    0x8(%ebp),%eax
c010105c:	66 89 02             	mov    %ax,(%edx)
        break;
c010105f:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101060:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0101067:	66 3d cf 07          	cmp    $0x7cf,%ax
c010106b:	76 5b                	jbe    c01010c8 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010106d:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0101072:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101078:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c010107d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101084:	00 
c0101085:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101089:	89 04 24             	mov    %eax,(%esp)
c010108c:	e8 d7 60 00 00       	call   c0107168 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101091:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101098:	eb 15                	jmp    c01010af <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010109a:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c010109f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01010a2:	01 d2                	add    %edx,%edx
c01010a4:	01 d0                	add    %edx,%eax
c01010a6:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01010ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01010af:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01010b6:	7e e2                	jle    c010109a <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c01010b8:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c01010bf:	83 e8 50             	sub    $0x50,%eax
c01010c2:	66 a3 a4 ce 11 c0    	mov    %ax,0xc011cea4
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01010c8:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c01010cf:	0f b7 c0             	movzwl %ax,%eax
c01010d2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01010d6:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01010da:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010de:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010e2:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01010e3:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c01010ea:	66 c1 e8 08          	shr    $0x8,%ax
c01010ee:	0f b6 c0             	movzbl %al,%eax
c01010f1:	0f b7 15 a6 ce 11 c0 	movzwl 0xc011cea6,%edx
c01010f8:	83 c2 01             	add    $0x1,%edx
c01010fb:	0f b7 d2             	movzwl %dx,%edx
c01010fe:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101102:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101105:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101109:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010110d:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010110e:	0f b7 05 a6 ce 11 c0 	movzwl 0xc011cea6,%eax
c0101115:	0f b7 c0             	movzwl %ax,%eax
c0101118:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010111c:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101120:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101124:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101128:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101129:	0f b7 05 a4 ce 11 c0 	movzwl 0xc011cea4,%eax
c0101130:	0f b6 c0             	movzbl %al,%eax
c0101133:	0f b7 15 a6 ce 11 c0 	movzwl 0xc011cea6,%edx
c010113a:	83 c2 01             	add    $0x1,%edx
c010113d:	0f b7 d2             	movzwl %dx,%edx
c0101140:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101144:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101147:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010114b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010114f:	ee                   	out    %al,(%dx)
}
c0101150:	83 c4 34             	add    $0x34,%esp
c0101153:	5b                   	pop    %ebx
c0101154:	5d                   	pop    %ebp
c0101155:	c3                   	ret    

c0101156 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101156:	55                   	push   %ebp
c0101157:	89 e5                	mov    %esp,%ebp
c0101159:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010115c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101163:	eb 09                	jmp    c010116e <serial_putc_sub+0x18>
        delay();
c0101165:	e8 4f fb ff ff       	call   c0100cb9 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010116a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010116e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101174:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101178:	89 c2                	mov    %eax,%edx
c010117a:	ec                   	in     (%dx),%al
c010117b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010117e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101182:	0f b6 c0             	movzbl %al,%eax
c0101185:	83 e0 20             	and    $0x20,%eax
c0101188:	85 c0                	test   %eax,%eax
c010118a:	75 09                	jne    c0101195 <serial_putc_sub+0x3f>
c010118c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101193:	7e d0                	jle    c0101165 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101195:	8b 45 08             	mov    0x8(%ebp),%eax
c0101198:	0f b6 c0             	movzbl %al,%eax
c010119b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01011a1:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011a4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011a8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011ac:	ee                   	out    %al,(%dx)
}
c01011ad:	c9                   	leave  
c01011ae:	c3                   	ret    

c01011af <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01011af:	55                   	push   %ebp
c01011b0:	89 e5                	mov    %esp,%ebp
c01011b2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01011b5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011b9:	74 0d                	je     c01011c8 <serial_putc+0x19>
        serial_putc_sub(c);
c01011bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01011be:	89 04 24             	mov    %eax,(%esp)
c01011c1:	e8 90 ff ff ff       	call   c0101156 <serial_putc_sub>
c01011c6:	eb 24                	jmp    c01011ec <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c01011c8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011cf:	e8 82 ff ff ff       	call   c0101156 <serial_putc_sub>
        serial_putc_sub(' ');
c01011d4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01011db:	e8 76 ff ff ff       	call   c0101156 <serial_putc_sub>
        serial_putc_sub('\b');
c01011e0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011e7:	e8 6a ff ff ff       	call   c0101156 <serial_putc_sub>
    }
}
c01011ec:	c9                   	leave  
c01011ed:	c3                   	ret    

c01011ee <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01011ee:	55                   	push   %ebp
c01011ef:	89 e5                	mov    %esp,%ebp
c01011f1:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01011f4:	eb 33                	jmp    c0101229 <cons_intr+0x3b>
        if (c != 0) {
c01011f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01011fa:	74 2d                	je     c0101229 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01011fc:	a1 c4 d0 11 c0       	mov    0xc011d0c4,%eax
c0101201:	8d 50 01             	lea    0x1(%eax),%edx
c0101204:	89 15 c4 d0 11 c0    	mov    %edx,0xc011d0c4
c010120a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010120d:	88 90 c0 ce 11 c0    	mov    %dl,-0x3fee3140(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101213:	a1 c4 d0 11 c0       	mov    0xc011d0c4,%eax
c0101218:	3d 00 02 00 00       	cmp    $0x200,%eax
c010121d:	75 0a                	jne    c0101229 <cons_intr+0x3b>
                cons.wpos = 0;
c010121f:	c7 05 c4 d0 11 c0 00 	movl   $0x0,0xc011d0c4
c0101226:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101229:	8b 45 08             	mov    0x8(%ebp),%eax
c010122c:	ff d0                	call   *%eax
c010122e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101231:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101235:	75 bf                	jne    c01011f6 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101237:	c9                   	leave  
c0101238:	c3                   	ret    

c0101239 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101239:	55                   	push   %ebp
c010123a:	89 e5                	mov    %esp,%ebp
c010123c:	83 ec 10             	sub    $0x10,%esp
c010123f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101245:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101249:	89 c2                	mov    %eax,%edx
c010124b:	ec                   	in     (%dx),%al
c010124c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010124f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101253:	0f b6 c0             	movzbl %al,%eax
c0101256:	83 e0 01             	and    $0x1,%eax
c0101259:	85 c0                	test   %eax,%eax
c010125b:	75 07                	jne    c0101264 <serial_proc_data+0x2b>
        return -1;
c010125d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101262:	eb 2a                	jmp    c010128e <serial_proc_data+0x55>
c0101264:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010126a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010126e:	89 c2                	mov    %eax,%edx
c0101270:	ec                   	in     (%dx),%al
c0101271:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101274:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101278:	0f b6 c0             	movzbl %al,%eax
c010127b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010127e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101282:	75 07                	jne    c010128b <serial_proc_data+0x52>
        c = '\b';
c0101284:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010128e:	c9                   	leave  
c010128f:	c3                   	ret    

c0101290 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101290:	55                   	push   %ebp
c0101291:	89 e5                	mov    %esp,%ebp
c0101293:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101296:	a1 a8 ce 11 c0       	mov    0xc011cea8,%eax
c010129b:	85 c0                	test   %eax,%eax
c010129d:	74 0c                	je     c01012ab <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010129f:	c7 04 24 39 12 10 c0 	movl   $0xc0101239,(%esp)
c01012a6:	e8 43 ff ff ff       	call   c01011ee <cons_intr>
    }
}
c01012ab:	c9                   	leave  
c01012ac:	c3                   	ret    

c01012ad <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01012ad:	55                   	push   %ebp
c01012ae:	89 e5                	mov    %esp,%ebp
c01012b0:	83 ec 38             	sub    $0x38,%esp
c01012b3:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012b9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01012bd:	89 c2                	mov    %eax,%edx
c01012bf:	ec                   	in     (%dx),%al
c01012c0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01012c3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01012c7:	0f b6 c0             	movzbl %al,%eax
c01012ca:	83 e0 01             	and    $0x1,%eax
c01012cd:	85 c0                	test   %eax,%eax
c01012cf:	75 0a                	jne    c01012db <kbd_proc_data+0x2e>
        return -1;
c01012d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01012d6:	e9 59 01 00 00       	jmp    c0101434 <kbd_proc_data+0x187>
c01012db:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01012e5:	89 c2                	mov    %eax,%edx
c01012e7:	ec                   	in     (%dx),%al
c01012e8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01012eb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01012ef:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01012f2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01012f6:	75 17                	jne    c010130f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01012f8:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c01012fd:	83 c8 40             	or     $0x40,%eax
c0101300:	a3 c8 d0 11 c0       	mov    %eax,0xc011d0c8
        return 0;
c0101305:	b8 00 00 00 00       	mov    $0x0,%eax
c010130a:	e9 25 01 00 00       	jmp    c0101434 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c010130f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101313:	84 c0                	test   %al,%al
c0101315:	79 47                	jns    c010135e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101317:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c010131c:	83 e0 40             	and    $0x40,%eax
c010131f:	85 c0                	test   %eax,%eax
c0101321:	75 09                	jne    c010132c <kbd_proc_data+0x7f>
c0101323:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101327:	83 e0 7f             	and    $0x7f,%eax
c010132a:	eb 04                	jmp    c0101330 <kbd_proc_data+0x83>
c010132c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101330:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101333:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101337:	0f b6 80 60 c0 11 c0 	movzbl -0x3fee3fa0(%eax),%eax
c010133e:	83 c8 40             	or     $0x40,%eax
c0101341:	0f b6 c0             	movzbl %al,%eax
c0101344:	f7 d0                	not    %eax
c0101346:	89 c2                	mov    %eax,%edx
c0101348:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c010134d:	21 d0                	and    %edx,%eax
c010134f:	a3 c8 d0 11 c0       	mov    %eax,0xc011d0c8
        return 0;
c0101354:	b8 00 00 00 00       	mov    $0x0,%eax
c0101359:	e9 d6 00 00 00       	jmp    c0101434 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c010135e:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c0101363:	83 e0 40             	and    $0x40,%eax
c0101366:	85 c0                	test   %eax,%eax
c0101368:	74 11                	je     c010137b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010136a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010136e:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c0101373:	83 e0 bf             	and    $0xffffffbf,%eax
c0101376:	a3 c8 d0 11 c0       	mov    %eax,0xc011d0c8
    }

    shift |= shiftcode[data];
c010137b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010137f:	0f b6 80 60 c0 11 c0 	movzbl -0x3fee3fa0(%eax),%eax
c0101386:	0f b6 d0             	movzbl %al,%edx
c0101389:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c010138e:	09 d0                	or     %edx,%eax
c0101390:	a3 c8 d0 11 c0       	mov    %eax,0xc011d0c8
    shift ^= togglecode[data];
c0101395:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101399:	0f b6 80 60 c1 11 c0 	movzbl -0x3fee3ea0(%eax),%eax
c01013a0:	0f b6 d0             	movzbl %al,%edx
c01013a3:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c01013a8:	31 d0                	xor    %edx,%eax
c01013aa:	a3 c8 d0 11 c0       	mov    %eax,0xc011d0c8

    c = charcode[shift & (CTL | SHIFT)][data];
c01013af:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c01013b4:	83 e0 03             	and    $0x3,%eax
c01013b7:	8b 14 85 60 c5 11 c0 	mov    -0x3fee3aa0(,%eax,4),%edx
c01013be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013c2:	01 d0                	add    %edx,%eax
c01013c4:	0f b6 00             	movzbl (%eax),%eax
c01013c7:	0f b6 c0             	movzbl %al,%eax
c01013ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01013cd:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c01013d2:	83 e0 08             	and    $0x8,%eax
c01013d5:	85 c0                	test   %eax,%eax
c01013d7:	74 22                	je     c01013fb <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01013d9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01013dd:	7e 0c                	jle    c01013eb <kbd_proc_data+0x13e>
c01013df:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01013e3:	7f 06                	jg     c01013eb <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01013e5:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01013e9:	eb 10                	jmp    c01013fb <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01013eb:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01013ef:	7e 0a                	jle    c01013fb <kbd_proc_data+0x14e>
c01013f1:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01013f5:	7f 04                	jg     c01013fb <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01013f7:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01013fb:	a1 c8 d0 11 c0       	mov    0xc011d0c8,%eax
c0101400:	f7 d0                	not    %eax
c0101402:	83 e0 06             	and    $0x6,%eax
c0101405:	85 c0                	test   %eax,%eax
c0101407:	75 28                	jne    c0101431 <kbd_proc_data+0x184>
c0101409:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101410:	75 1f                	jne    c0101431 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101412:	c7 04 24 55 75 10 c0 	movl   $0xc0107555,(%esp)
c0101419:	e8 a9 ed ff ff       	call   c01001c7 <cprintf>
c010141e:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101424:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101428:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010142c:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101430:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101431:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101434:	c9                   	leave  
c0101435:	c3                   	ret    

c0101436 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101436:	55                   	push   %ebp
c0101437:	89 e5                	mov    %esp,%ebp
c0101439:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010143c:	c7 04 24 ad 12 10 c0 	movl   $0xc01012ad,(%esp)
c0101443:	e8 a6 fd ff ff       	call   c01011ee <cons_intr>
}
c0101448:	c9                   	leave  
c0101449:	c3                   	ret    

c010144a <kbd_init>:

static void
kbd_init(void) {
c010144a:	55                   	push   %ebp
c010144b:	89 e5                	mov    %esp,%ebp
c010144d:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101450:	e8 e1 ff ff ff       	call   c0101436 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101455:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010145c:	e8 3d 01 00 00       	call   c010159e <pic_enable>
}
c0101461:	c9                   	leave  
c0101462:	c3                   	ret    

c0101463 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101463:	55                   	push   %ebp
c0101464:	89 e5                	mov    %esp,%ebp
c0101466:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101469:	e8 93 f8 ff ff       	call   c0100d01 <cga_init>
    serial_init();
c010146e:	e8 74 f9 ff ff       	call   c0100de7 <serial_init>
    kbd_init();
c0101473:	e8 d2 ff ff ff       	call   c010144a <kbd_init>
    if (!serial_exists) {
c0101478:	a1 a8 ce 11 c0       	mov    0xc011cea8,%eax
c010147d:	85 c0                	test   %eax,%eax
c010147f:	75 0c                	jne    c010148d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101481:	c7 04 24 61 75 10 c0 	movl   $0xc0107561,(%esp)
c0101488:	e8 3a ed ff ff       	call   c01001c7 <cprintf>
    }
}
c010148d:	c9                   	leave  
c010148e:	c3                   	ret    

c010148f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010148f:	55                   	push   %ebp
c0101490:	89 e5                	mov    %esp,%ebp
c0101492:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101495:	e8 e2 f7 ff ff       	call   c0100c7c <__intr_save>
c010149a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010149d:	8b 45 08             	mov    0x8(%ebp),%eax
c01014a0:	89 04 24             	mov    %eax,(%esp)
c01014a3:	e8 9b fa ff ff       	call   c0100f43 <lpt_putc>
        cga_putc(c);
c01014a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01014ab:	89 04 24             	mov    %eax,(%esp)
c01014ae:	e8 cf fa ff ff       	call   c0100f82 <cga_putc>
        serial_putc(c);
c01014b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01014b6:	89 04 24             	mov    %eax,(%esp)
c01014b9:	e8 f1 fc ff ff       	call   c01011af <serial_putc>
    }
    local_intr_restore(intr_flag);
c01014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014c1:	89 04 24             	mov    %eax,(%esp)
c01014c4:	e8 dd f7 ff ff       	call   c0100ca6 <__intr_restore>
}
c01014c9:	c9                   	leave  
c01014ca:	c3                   	ret    

c01014cb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01014cb:	55                   	push   %ebp
c01014cc:	89 e5                	mov    %esp,%ebp
c01014ce:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01014d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01014d8:	e8 9f f7 ff ff       	call   c0100c7c <__intr_save>
c01014dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01014e0:	e8 ab fd ff ff       	call   c0101290 <serial_intr>
        kbd_intr();
c01014e5:	e8 4c ff ff ff       	call   c0101436 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01014ea:	8b 15 c0 d0 11 c0    	mov    0xc011d0c0,%edx
c01014f0:	a1 c4 d0 11 c0       	mov    0xc011d0c4,%eax
c01014f5:	39 c2                	cmp    %eax,%edx
c01014f7:	74 31                	je     c010152a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01014f9:	a1 c0 d0 11 c0       	mov    0xc011d0c0,%eax
c01014fe:	8d 50 01             	lea    0x1(%eax),%edx
c0101501:	89 15 c0 d0 11 c0    	mov    %edx,0xc011d0c0
c0101507:	0f b6 80 c0 ce 11 c0 	movzbl -0x3fee3140(%eax),%eax
c010150e:	0f b6 c0             	movzbl %al,%eax
c0101511:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101514:	a1 c0 d0 11 c0       	mov    0xc011d0c0,%eax
c0101519:	3d 00 02 00 00       	cmp    $0x200,%eax
c010151e:	75 0a                	jne    c010152a <cons_getc+0x5f>
                cons.rpos = 0;
c0101520:	c7 05 c0 d0 11 c0 00 	movl   $0x0,0xc011d0c0
c0101527:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010152d:	89 04 24             	mov    %eax,(%esp)
c0101530:	e8 71 f7 ff ff       	call   c0100ca6 <__intr_restore>
    return c;
c0101535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101538:	c9                   	leave  
c0101539:	c3                   	ret    

c010153a <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010153a:	55                   	push   %ebp
c010153b:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010153d:	fb                   	sti    
    sti();
}
c010153e:	5d                   	pop    %ebp
c010153f:	c3                   	ret    

c0101540 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101540:	55                   	push   %ebp
c0101541:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101543:	fa                   	cli    
    cli();
}
c0101544:	5d                   	pop    %ebp
c0101545:	c3                   	ret    

c0101546 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101546:	55                   	push   %ebp
c0101547:	89 e5                	mov    %esp,%ebp
c0101549:	83 ec 14             	sub    $0x14,%esp
c010154c:	8b 45 08             	mov    0x8(%ebp),%eax
c010154f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101553:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101557:	66 a3 70 c5 11 c0    	mov    %ax,0xc011c570
    if (did_init) {
c010155d:	a1 cc d0 11 c0       	mov    0xc011d0cc,%eax
c0101562:	85 c0                	test   %eax,%eax
c0101564:	74 36                	je     c010159c <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101566:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010156a:	0f b6 c0             	movzbl %al,%eax
c010156d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101573:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101576:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010157a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010157e:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010157f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101583:	66 c1 e8 08          	shr    $0x8,%ax
c0101587:	0f b6 c0             	movzbl %al,%eax
c010158a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101590:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101593:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101597:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010159b:	ee                   	out    %al,(%dx)
    }
}
c010159c:	c9                   	leave  
c010159d:	c3                   	ret    

c010159e <pic_enable>:

void
pic_enable(unsigned int irq) {
c010159e:	55                   	push   %ebp
c010159f:	89 e5                	mov    %esp,%ebp
c01015a1:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01015a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01015a7:	ba 01 00 00 00       	mov    $0x1,%edx
c01015ac:	89 c1                	mov    %eax,%ecx
c01015ae:	d3 e2                	shl    %cl,%edx
c01015b0:	89 d0                	mov    %edx,%eax
c01015b2:	f7 d0                	not    %eax
c01015b4:	89 c2                	mov    %eax,%edx
c01015b6:	0f b7 05 70 c5 11 c0 	movzwl 0xc011c570,%eax
c01015bd:	21 d0                	and    %edx,%eax
c01015bf:	0f b7 c0             	movzwl %ax,%eax
c01015c2:	89 04 24             	mov    %eax,(%esp)
c01015c5:	e8 7c ff ff ff       	call   c0101546 <pic_setmask>
}
c01015ca:	c9                   	leave  
c01015cb:	c3                   	ret    

c01015cc <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01015cc:	55                   	push   %ebp
c01015cd:	89 e5                	mov    %esp,%ebp
c01015cf:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01015d2:	c7 05 cc d0 11 c0 01 	movl   $0x1,0xc011d0cc
c01015d9:	00 00 00 
c01015dc:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01015e2:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01015e6:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01015ea:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01015ee:	ee                   	out    %al,(%dx)
c01015ef:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01015f5:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c01015f9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01015fd:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101601:	ee                   	out    %al,(%dx)
c0101602:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101608:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c010160c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101610:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101614:	ee                   	out    %al,(%dx)
c0101615:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010161b:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010161f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101623:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101627:	ee                   	out    %al,(%dx)
c0101628:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010162e:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0101632:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101636:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010163a:	ee                   	out    %al,(%dx)
c010163b:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0101641:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0101645:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101649:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010164d:	ee                   	out    %al,(%dx)
c010164e:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101654:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0101658:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010165c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101660:	ee                   	out    %al,(%dx)
c0101661:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101667:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010166b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010166f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101673:	ee                   	out    %al,(%dx)
c0101674:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010167a:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010167e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101682:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101686:	ee                   	out    %al,(%dx)
c0101687:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010168d:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101691:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101695:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101699:	ee                   	out    %al,(%dx)
c010169a:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01016a0:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01016a4:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01016a8:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01016ac:	ee                   	out    %al,(%dx)
c01016ad:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01016b3:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01016b7:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01016bb:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01016bf:	ee                   	out    %al,(%dx)
c01016c0:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01016c6:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01016ca:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01016ce:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01016d2:	ee                   	out    %al,(%dx)
c01016d3:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01016d9:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01016dd:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01016e1:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01016e5:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01016e6:	0f b7 05 70 c5 11 c0 	movzwl 0xc011c570,%eax
c01016ed:	66 83 f8 ff          	cmp    $0xffff,%ax
c01016f1:	74 12                	je     c0101705 <pic_init+0x139>
        pic_setmask(irq_mask);
c01016f3:	0f b7 05 70 c5 11 c0 	movzwl 0xc011c570,%eax
c01016fa:	0f b7 c0             	movzwl %ax,%eax
c01016fd:	89 04 24             	mov    %eax,(%esp)
c0101700:	e8 41 fe ff ff       	call   c0101546 <pic_setmask>
    }
}
c0101705:	c9                   	leave  
c0101706:	c3                   	ret    

c0101707 <print_ticks>:
//#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101707:	55                   	push   %ebp
c0101708:	89 e5                	mov    %esp,%ebp
c010170a:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010170d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101714:	00 
c0101715:	c7 04 24 80 75 10 c0 	movl   $0xc0107580,(%esp)
c010171c:	e8 a6 ea ff ff       	call   c01001c7 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0101721:	c9                   	leave  
c0101722:	c3                   	ret    

c0101723 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0101723:	55                   	push   %ebp
c0101724:	89 e5                	mov    %esp,%ebp
c0101726:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; i++) {
c0101729:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101730:	e9 91 01 00 00       	jmp    c01018c6 <idt_init+0x1a3>
        if (i != T_SYSCALL) {
c0101735:	81 7d fc 80 00 00 00 	cmpl   $0x80,-0x4(%ebp)
c010173c:	0f 84 c4 00 00 00    	je     c0101806 <idt_init+0xe3>
            SETGATE(idt[i], 0, 8, __vectors[i], 0);
c0101742:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101745:	8b 04 85 00 c6 11 c0 	mov    -0x3fee3a00(,%eax,4),%eax
c010174c:	89 c2                	mov    %eax,%edx
c010174e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101751:	66 89 14 c5 e0 d0 11 	mov    %dx,-0x3fee2f20(,%eax,8)
c0101758:	c0 
c0101759:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010175c:	66 c7 04 c5 e2 d0 11 	movw   $0x8,-0x3fee2f1e(,%eax,8)
c0101763:	c0 08 00 
c0101766:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101769:	0f b6 14 c5 e4 d0 11 	movzbl -0x3fee2f1c(,%eax,8),%edx
c0101770:	c0 
c0101771:	83 e2 e0             	and    $0xffffffe0,%edx
c0101774:	88 14 c5 e4 d0 11 c0 	mov    %dl,-0x3fee2f1c(,%eax,8)
c010177b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010177e:	0f b6 14 c5 e4 d0 11 	movzbl -0x3fee2f1c(,%eax,8),%edx
c0101785:	c0 
c0101786:	83 e2 1f             	and    $0x1f,%edx
c0101789:	88 14 c5 e4 d0 11 c0 	mov    %dl,-0x3fee2f1c(,%eax,8)
c0101790:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101793:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c010179a:	c0 
c010179b:	83 e2 f0             	and    $0xfffffff0,%edx
c010179e:	83 ca 0e             	or     $0xe,%edx
c01017a1:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c01017a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ab:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c01017b2:	c0 
c01017b3:	83 e2 ef             	and    $0xffffffef,%edx
c01017b6:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c01017bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017c0:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c01017c7:	c0 
c01017c8:	83 e2 9f             	and    $0xffffff9f,%edx
c01017cb:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c01017d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017d5:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c01017dc:	c0 
c01017dd:	83 ca 80             	or     $0xffffff80,%edx
c01017e0:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c01017e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ea:	8b 04 85 00 c6 11 c0 	mov    -0x3fee3a00(,%eax,4),%eax
c01017f1:	c1 e8 10             	shr    $0x10,%eax
c01017f4:	89 c2                	mov    %eax,%edx
c01017f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017f9:	66 89 14 c5 e6 d0 11 	mov    %dx,-0x3fee2f1a(,%eax,8)
c0101800:	c0 
c0101801:	e9 bc 00 00 00       	jmp    c01018c2 <idt_init+0x19f>
        } else {
            SETGATE(idt[i], 1, 8, __vectors[i], 3);
c0101806:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101809:	8b 04 85 00 c6 11 c0 	mov    -0x3fee3a00(,%eax,4),%eax
c0101810:	89 c2                	mov    %eax,%edx
c0101812:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101815:	66 89 14 c5 e0 d0 11 	mov    %dx,-0x3fee2f20(,%eax,8)
c010181c:	c0 
c010181d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101820:	66 c7 04 c5 e2 d0 11 	movw   $0x8,-0x3fee2f1e(,%eax,8)
c0101827:	c0 08 00 
c010182a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010182d:	0f b6 14 c5 e4 d0 11 	movzbl -0x3fee2f1c(,%eax,8),%edx
c0101834:	c0 
c0101835:	83 e2 e0             	and    $0xffffffe0,%edx
c0101838:	88 14 c5 e4 d0 11 c0 	mov    %dl,-0x3fee2f1c(,%eax,8)
c010183f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101842:	0f b6 14 c5 e4 d0 11 	movzbl -0x3fee2f1c(,%eax,8),%edx
c0101849:	c0 
c010184a:	83 e2 1f             	and    $0x1f,%edx
c010184d:	88 14 c5 e4 d0 11 c0 	mov    %dl,-0x3fee2f1c(,%eax,8)
c0101854:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101857:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c010185e:	c0 
c010185f:	83 ca 0f             	or     $0xf,%edx
c0101862:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c0101869:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010186c:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c0101873:	c0 
c0101874:	83 e2 ef             	and    $0xffffffef,%edx
c0101877:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c010187e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101881:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c0101888:	c0 
c0101889:	83 ca 60             	or     $0x60,%edx
c010188c:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c0101893:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101896:	0f b6 14 c5 e5 d0 11 	movzbl -0x3fee2f1b(,%eax,8),%edx
c010189d:	c0 
c010189e:	83 ca 80             	or     $0xffffff80,%edx
c01018a1:	88 14 c5 e5 d0 11 c0 	mov    %dl,-0x3fee2f1b(,%eax,8)
c01018a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ab:	8b 04 85 00 c6 11 c0 	mov    -0x3fee3a00(,%eax,4),%eax
c01018b2:	c1 e8 10             	shr    $0x10,%eax
c01018b5:	89 c2                	mov    %eax,%edx
c01018b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ba:	66 89 14 c5 e6 d0 11 	mov    %dx,-0x3fee2f1a(,%eax,8)
c01018c1:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; i++) {
c01018c2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01018c6:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01018cd:	0f 8e 62 fe ff ff    	jle    c0101735 <idt_init+0x12>
c01018d3:	c7 45 f8 80 c5 11 c0 	movl   $0xc011c580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01018da:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01018dd:	0f 01 18             	lidtl  (%eax)
        } else {
            SETGATE(idt[i], 1, 8, __vectors[i], 3);
        }
    }
    lidt(&idt_pd);
}
c01018e0:	c9                   	leave  
c01018e1:	c3                   	ret    

c01018e2 <trapname>:

static const char *
trapname(int trapno) {
c01018e2:	55                   	push   %ebp
c01018e3:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01018e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01018e8:	83 f8 13             	cmp    $0x13,%eax
c01018eb:	77 0c                	ja     c01018f9 <trapname+0x17>
        return excnames[trapno];
c01018ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f0:	8b 04 85 00 79 10 c0 	mov    -0x3fef8700(,%eax,4),%eax
c01018f7:	eb 18                	jmp    c0101911 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01018f9:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01018fd:	7e 0d                	jle    c010190c <trapname+0x2a>
c01018ff:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101903:	7f 07                	jg     c010190c <trapname+0x2a>
        return "Hardware Interrupt";
c0101905:	b8 8a 75 10 c0       	mov    $0xc010758a,%eax
c010190a:	eb 05                	jmp    c0101911 <trapname+0x2f>
    }
    return "(unknown trap)";
c010190c:	b8 9d 75 10 c0       	mov    $0xc010759d,%eax
}
c0101911:	5d                   	pop    %ebp
c0101912:	c3                   	ret    

c0101913 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101913:	55                   	push   %ebp
c0101914:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101916:	8b 45 08             	mov    0x8(%ebp),%eax
c0101919:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010191d:	66 83 f8 08          	cmp    $0x8,%ax
c0101921:	0f 94 c0             	sete   %al
c0101924:	0f b6 c0             	movzbl %al,%eax
}
c0101927:	5d                   	pop    %ebp
c0101928:	c3                   	ret    

c0101929 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101929:	55                   	push   %ebp
c010192a:	89 e5                	mov    %esp,%ebp
c010192c:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010192f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101932:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101936:	c7 04 24 de 75 10 c0 	movl   $0xc01075de,(%esp)
c010193d:	e8 85 e8 ff ff       	call   c01001c7 <cprintf>
    print_regs(&tf->tf_regs);
c0101942:	8b 45 08             	mov    0x8(%ebp),%eax
c0101945:	89 04 24             	mov    %eax,(%esp)
c0101948:	e8 a1 01 00 00       	call   c0101aee <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010194d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101950:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101954:	0f b7 c0             	movzwl %ax,%eax
c0101957:	89 44 24 04          	mov    %eax,0x4(%esp)
c010195b:	c7 04 24 ef 75 10 c0 	movl   $0xc01075ef,(%esp)
c0101962:	e8 60 e8 ff ff       	call   c01001c7 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101967:	8b 45 08             	mov    0x8(%ebp),%eax
c010196a:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010196e:	0f b7 c0             	movzwl %ax,%eax
c0101971:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101975:	c7 04 24 02 76 10 c0 	movl   $0xc0107602,(%esp)
c010197c:	e8 46 e8 ff ff       	call   c01001c7 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101981:	8b 45 08             	mov    0x8(%ebp),%eax
c0101984:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101988:	0f b7 c0             	movzwl %ax,%eax
c010198b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010198f:	c7 04 24 15 76 10 c0 	movl   $0xc0107615,(%esp)
c0101996:	e8 2c e8 ff ff       	call   c01001c7 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010199b:	8b 45 08             	mov    0x8(%ebp),%eax
c010199e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01019a2:	0f b7 c0             	movzwl %ax,%eax
c01019a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019a9:	c7 04 24 28 76 10 c0 	movl   $0xc0107628,(%esp)
c01019b0:	e8 12 e8 ff ff       	call   c01001c7 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01019b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b8:	8b 40 30             	mov    0x30(%eax),%eax
c01019bb:	89 04 24             	mov    %eax,(%esp)
c01019be:	e8 1f ff ff ff       	call   c01018e2 <trapname>
c01019c3:	8b 55 08             	mov    0x8(%ebp),%edx
c01019c6:	8b 52 30             	mov    0x30(%edx),%edx
c01019c9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01019cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01019d1:	c7 04 24 3b 76 10 c0 	movl   $0xc010763b,(%esp)
c01019d8:	e8 ea e7 ff ff       	call   c01001c7 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01019dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01019e0:	8b 40 34             	mov    0x34(%eax),%eax
c01019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019e7:	c7 04 24 4d 76 10 c0 	movl   $0xc010764d,(%esp)
c01019ee:	e8 d4 e7 ff ff       	call   c01001c7 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01019f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f6:	8b 40 38             	mov    0x38(%eax),%eax
c01019f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019fd:	c7 04 24 5c 76 10 c0 	movl   $0xc010765c,(%esp)
c0101a04:	e8 be e7 ff ff       	call   c01001c7 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101a09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a0c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a10:	0f b7 c0             	movzwl %ax,%eax
c0101a13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a17:	c7 04 24 6b 76 10 c0 	movl   $0xc010766b,(%esp)
c0101a1e:	e8 a4 e7 ff ff       	call   c01001c7 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101a23:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a26:	8b 40 40             	mov    0x40(%eax),%eax
c0101a29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a2d:	c7 04 24 7e 76 10 c0 	movl   $0xc010767e,(%esp)
c0101a34:	e8 8e e7 ff ff       	call   c01001c7 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101a39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101a40:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101a47:	eb 3e                	jmp    c0101a87 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4c:	8b 50 40             	mov    0x40(%eax),%edx
c0101a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101a52:	21 d0                	and    %edx,%eax
c0101a54:	85 c0                	test   %eax,%eax
c0101a56:	74 28                	je     c0101a80 <print_trapframe+0x157>
c0101a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a5b:	8b 04 85 a0 c5 11 c0 	mov    -0x3fee3a60(,%eax,4),%eax
c0101a62:	85 c0                	test   %eax,%eax
c0101a64:	74 1a                	je     c0101a80 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a69:	8b 04 85 a0 c5 11 c0 	mov    -0x3fee3a60(,%eax,4),%eax
c0101a70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a74:	c7 04 24 8d 76 10 c0 	movl   $0xc010768d,(%esp)
c0101a7b:	e8 47 e7 ff ff       	call   c01001c7 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101a80:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101a84:	d1 65 f0             	shll   -0x10(%ebp)
c0101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a8a:	83 f8 17             	cmp    $0x17,%eax
c0101a8d:	76 ba                	jbe    c0101a49 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a92:	8b 40 40             	mov    0x40(%eax),%eax
c0101a95:	25 00 30 00 00       	and    $0x3000,%eax
c0101a9a:	c1 e8 0c             	shr    $0xc,%eax
c0101a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa1:	c7 04 24 91 76 10 c0 	movl   $0xc0107691,(%esp)
c0101aa8:	e8 1a e7 ff ff       	call   c01001c7 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab0:	89 04 24             	mov    %eax,(%esp)
c0101ab3:	e8 5b fe ff ff       	call   c0101913 <trap_in_kernel>
c0101ab8:	85 c0                	test   %eax,%eax
c0101aba:	75 30                	jne    c0101aec <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abf:	8b 40 44             	mov    0x44(%eax),%eax
c0101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac6:	c7 04 24 9a 76 10 c0 	movl   $0xc010769a,(%esp)
c0101acd:	e8 f5 e6 ff ff       	call   c01001c7 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101ad9:	0f b7 c0             	movzwl %ax,%eax
c0101adc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae0:	c7 04 24 a9 76 10 c0 	movl   $0xc01076a9,(%esp)
c0101ae7:	e8 db e6 ff ff       	call   c01001c7 <cprintf>
    }
}
c0101aec:	c9                   	leave  
c0101aed:	c3                   	ret    

c0101aee <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101aee:	55                   	push   %ebp
c0101aef:	89 e5                	mov    %esp,%ebp
c0101af1:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101af4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af7:	8b 00                	mov    (%eax),%eax
c0101af9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101afd:	c7 04 24 bc 76 10 c0 	movl   $0xc01076bc,(%esp)
c0101b04:	e8 be e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101b09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0c:	8b 40 04             	mov    0x4(%eax),%eax
c0101b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b13:	c7 04 24 cb 76 10 c0 	movl   $0xc01076cb,(%esp)
c0101b1a:	e8 a8 e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b22:	8b 40 08             	mov    0x8(%eax),%eax
c0101b25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b29:	c7 04 24 da 76 10 c0 	movl   $0xc01076da,(%esp)
c0101b30:	e8 92 e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101b35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b38:	8b 40 0c             	mov    0xc(%eax),%eax
c0101b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3f:	c7 04 24 e9 76 10 c0 	movl   $0xc01076e9,(%esp)
c0101b46:	e8 7c e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4e:	8b 40 10             	mov    0x10(%eax),%eax
c0101b51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b55:	c7 04 24 f8 76 10 c0 	movl   $0xc01076f8,(%esp)
c0101b5c:	e8 66 e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b64:	8b 40 14             	mov    0x14(%eax),%eax
c0101b67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b6b:	c7 04 24 07 77 10 c0 	movl   $0xc0107707,(%esp)
c0101b72:	e8 50 e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7a:	8b 40 18             	mov    0x18(%eax),%eax
c0101b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b81:	c7 04 24 16 77 10 c0 	movl   $0xc0107716,(%esp)
c0101b88:	e8 3a e6 ff ff       	call   c01001c7 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b90:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101b93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b97:	c7 04 24 25 77 10 c0 	movl   $0xc0107725,(%esp)
c0101b9e:	e8 24 e6 ff ff       	call   c01001c7 <cprintf>
}
c0101ba3:	c9                   	leave  
c0101ba4:	c3                   	ret    

c0101ba5 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0101ba5:	55                   	push   %ebp
c0101ba6:	89 e5                	mov    %esp,%ebp
c0101ba8:	83 ec 28             	sub    $0x28,%esp
    char c;
    static int count = 0;

    int ret;

    switch (tf->tf_trapno) {
c0101bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bae:	8b 40 30             	mov    0x30(%eax),%eax
c0101bb1:	83 f8 24             	cmp    $0x24,%eax
c0101bb4:	0f 84 a8 00 00 00    	je     c0101c62 <trap_dispatch+0xbd>
c0101bba:	83 f8 24             	cmp    $0x24,%eax
c0101bbd:	77 18                	ja     c0101bd7 <trap_dispatch+0x32>
c0101bbf:	83 f8 20             	cmp    $0x20,%eax
c0101bc2:	74 52                	je     c0101c16 <trap_dispatch+0x71>
c0101bc4:	83 f8 21             	cmp    $0x21,%eax
c0101bc7:	0f 84 bb 00 00 00    	je     c0101c88 <trap_dispatch+0xe3>
c0101bcd:	83 f8 0e             	cmp    $0xe,%eax
c0101bd0:	74 28                	je     c0101bfa <trap_dispatch+0x55>
c0101bd2:	e9 f3 00 00 00       	jmp    c0101cca <trap_dispatch+0x125>
c0101bd7:	83 f8 2e             	cmp    $0x2e,%eax
c0101bda:	0f 82 ea 00 00 00    	jb     c0101cca <trap_dispatch+0x125>
c0101be0:	83 f8 2f             	cmp    $0x2f,%eax
c0101be3:	0f 86 19 01 00 00    	jbe    c0101d02 <trap_dispatch+0x15d>
c0101be9:	83 e8 78             	sub    $0x78,%eax
c0101bec:	83 f8 01             	cmp    $0x1,%eax
c0101bef:	0f 87 d5 00 00 00    	ja     c0101cca <trap_dispatch+0x125>
c0101bf5:	e9 b4 00 00 00       	jmp    c0101cae <trap_dispatch+0x109>
    case T_PGFLT:  //page fault
        panic("pgfault execption!!!\n");
c0101bfa:	c7 44 24 08 34 77 10 	movl   $0xc0107734,0x8(%esp)
c0101c01:	c0 
c0101c02:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0101c09:	00 
c0101c0a:	c7 04 24 4a 77 10 c0 	movl   $0xc010774a,(%esp)
c0101c11:	e8 47 ef ff ff       	call   c0100b5d <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        count++;
c0101c16:	a1 e4 d8 11 c0       	mov    0xc011d8e4,%eax
c0101c1b:	83 c0 01             	add    $0x1,%eax
c0101c1e:	a3 e4 d8 11 c0       	mov    %eax,0xc011d8e4
        if (count % 100 == 0) {
c0101c23:	8b 0d e4 d8 11 c0    	mov    0xc011d8e4,%ecx
c0101c29:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101c2e:	89 c8                	mov    %ecx,%eax
c0101c30:	f7 ea                	imul   %edx
c0101c32:	c1 fa 05             	sar    $0x5,%edx
c0101c35:	89 c8                	mov    %ecx,%eax
c0101c37:	c1 f8 1f             	sar    $0x1f,%eax
c0101c3a:	29 c2                	sub    %eax,%edx
c0101c3c:	89 d0                	mov    %edx,%eax
c0101c3e:	6b c0 64             	imul   $0x64,%eax,%eax
c0101c41:	29 c1                	sub    %eax,%ecx
c0101c43:	89 c8                	mov    %ecx,%eax
c0101c45:	85 c0                	test   %eax,%eax
c0101c47:	75 14                	jne    c0101c5d <trap_dispatch+0xb8>
            print_ticks();
c0101c49:	e8 b9 fa ff ff       	call   c0101707 <print_ticks>
            count = 0;
c0101c4e:	c7 05 e4 d8 11 c0 00 	movl   $0x0,0xc011d8e4
c0101c55:	00 00 00 
        }
        break;
c0101c58:	e9 a6 00 00 00       	jmp    c0101d03 <trap_dispatch+0x15e>
c0101c5d:	e9 a1 00 00 00       	jmp    c0101d03 <trap_dispatch+0x15e>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101c62:	e8 64 f8 ff ff       	call   c01014cb <cons_getc>
c0101c67:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101c6a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101c6e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101c72:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7a:	c7 04 24 5b 77 10 c0 	movl   $0xc010775b,(%esp)
c0101c81:	e8 41 e5 ff ff       	call   c01001c7 <cprintf>
        break;
c0101c86:	eb 7b                	jmp    c0101d03 <trap_dispatch+0x15e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101c88:	e8 3e f8 ff ff       	call   c01014cb <cons_getc>
c0101c8d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101c90:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101c94:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101c98:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca0:	c7 04 24 6d 77 10 c0 	movl   $0xc010776d,(%esp)
c0101ca7:	e8 1b e5 ff ff       	call   c01001c7 <cprintf>
        break;
c0101cac:	eb 55                	jmp    c0101d03 <trap_dispatch+0x15e>
    //LAB1 CHALLENGE 1 : 2012011346 you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101cae:	c7 44 24 08 7c 77 10 	movl   $0xc010777c,0x8(%esp)
c0101cb5:	c0 
c0101cb6:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0101cbd:	00 
c0101cbe:	c7 04 24 4a 77 10 c0 	movl   $0xc010774a,(%esp)
c0101cc5:	e8 93 ee ff ff       	call   c0100b5d <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101cca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ccd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101cd1:	0f b7 c0             	movzwl %ax,%eax
c0101cd4:	83 e0 03             	and    $0x3,%eax
c0101cd7:	85 c0                	test   %eax,%eax
c0101cd9:	75 28                	jne    c0101d03 <trap_dispatch+0x15e>
            print_trapframe(tf);
c0101cdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cde:	89 04 24             	mov    %eax,(%esp)
c0101ce1:	e8 43 fc ff ff       	call   c0101929 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101ce6:	c7 44 24 08 8c 77 10 	movl   $0xc010778c,0x8(%esp)
c0101ced:	c0 
c0101cee:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0101cf5:	00 
c0101cf6:	c7 04 24 4a 77 10 c0 	movl   $0xc010774a,(%esp)
c0101cfd:	e8 5b ee ff ff       	call   c0100b5d <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101d02:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101d03:	c9                   	leave  
c0101d04:	c3                   	ret    

c0101d05 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d05:	55                   	push   %ebp
c0101d06:	89 e5                	mov    %esp,%ebp
c0101d08:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d0e:	89 04 24             	mov    %eax,(%esp)
c0101d11:	e8 8f fe ff ff       	call   c0101ba5 <trap_dispatch>
}
c0101d16:	c9                   	leave  
c0101d17:	c3                   	ret    

c0101d18 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101d18:	1e                   	push   %ds
    pushl %es
c0101d19:	06                   	push   %es
    pushl %fs
c0101d1a:	0f a0                	push   %fs
    pushl %gs
c0101d1c:	0f a8                	push   %gs
    pushal
c0101d1e:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101d1f:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101d24:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101d26:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101d28:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101d29:	e8 d7 ff ff ff       	call   c0101d05 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101d2e:	5c                   	pop    %esp

c0101d2f <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101d2f:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101d30:	0f a9                	pop    %gs
    popl %fs
c0101d32:	0f a1                	pop    %fs
    popl %es
c0101d34:	07                   	pop    %es
    popl %ds
c0101d35:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101d36:	83 c4 08             	add    $0x8,%esp
    iret
c0101d39:	cf                   	iret   

c0101d3a <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0101d3a:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0101d3e:	e9 ec ff ff ff       	jmp    c0101d2f <__trapret>

c0101d43 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101d43:	6a 00                	push   $0x0
  pushl $0
c0101d45:	6a 00                	push   $0x0
  jmp __alltraps
c0101d47:	e9 cc ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d4c <vector1>:
.globl vector1
vector1:
  pushl $0
c0101d4c:	6a 00                	push   $0x0
  pushl $1
c0101d4e:	6a 01                	push   $0x1
  jmp __alltraps
c0101d50:	e9 c3 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d55 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101d55:	6a 00                	push   $0x0
  pushl $2
c0101d57:	6a 02                	push   $0x2
  jmp __alltraps
c0101d59:	e9 ba ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d5e <vector3>:
.globl vector3
vector3:
  pushl $0
c0101d5e:	6a 00                	push   $0x0
  pushl $3
c0101d60:	6a 03                	push   $0x3
  jmp __alltraps
c0101d62:	e9 b1 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d67 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101d67:	6a 00                	push   $0x0
  pushl $4
c0101d69:	6a 04                	push   $0x4
  jmp __alltraps
c0101d6b:	e9 a8 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d70 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101d70:	6a 00                	push   $0x0
  pushl $5
c0101d72:	6a 05                	push   $0x5
  jmp __alltraps
c0101d74:	e9 9f ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d79 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101d79:	6a 00                	push   $0x0
  pushl $6
c0101d7b:	6a 06                	push   $0x6
  jmp __alltraps
c0101d7d:	e9 96 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d82 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101d82:	6a 00                	push   $0x0
  pushl $7
c0101d84:	6a 07                	push   $0x7
  jmp __alltraps
c0101d86:	e9 8d ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d8b <vector8>:
.globl vector8
vector8:
  pushl $8
c0101d8b:	6a 08                	push   $0x8
  jmp __alltraps
c0101d8d:	e9 86 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d92 <vector9>:
.globl vector9
vector9:
  pushl $9
c0101d92:	6a 09                	push   $0x9
  jmp __alltraps
c0101d94:	e9 7f ff ff ff       	jmp    c0101d18 <__alltraps>

c0101d99 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101d99:	6a 0a                	push   $0xa
  jmp __alltraps
c0101d9b:	e9 78 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101da0 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101da0:	6a 0b                	push   $0xb
  jmp __alltraps
c0101da2:	e9 71 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101da7 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101da7:	6a 0c                	push   $0xc
  jmp __alltraps
c0101da9:	e9 6a ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dae <vector13>:
.globl vector13
vector13:
  pushl $13
c0101dae:	6a 0d                	push   $0xd
  jmp __alltraps
c0101db0:	e9 63 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101db5 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101db5:	6a 0e                	push   $0xe
  jmp __alltraps
c0101db7:	e9 5c ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dbc <vector15>:
.globl vector15
vector15:
  pushl $0
c0101dbc:	6a 00                	push   $0x0
  pushl $15
c0101dbe:	6a 0f                	push   $0xf
  jmp __alltraps
c0101dc0:	e9 53 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dc5 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101dc5:	6a 00                	push   $0x0
  pushl $16
c0101dc7:	6a 10                	push   $0x10
  jmp __alltraps
c0101dc9:	e9 4a ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dce <vector17>:
.globl vector17
vector17:
  pushl $17
c0101dce:	6a 11                	push   $0x11
  jmp __alltraps
c0101dd0:	e9 43 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dd5 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101dd5:	6a 00                	push   $0x0
  pushl $18
c0101dd7:	6a 12                	push   $0x12
  jmp __alltraps
c0101dd9:	e9 3a ff ff ff       	jmp    c0101d18 <__alltraps>

c0101dde <vector19>:
.globl vector19
vector19:
  pushl $0
c0101dde:	6a 00                	push   $0x0
  pushl $19
c0101de0:	6a 13                	push   $0x13
  jmp __alltraps
c0101de2:	e9 31 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101de7 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101de7:	6a 00                	push   $0x0
  pushl $20
c0101de9:	6a 14                	push   $0x14
  jmp __alltraps
c0101deb:	e9 28 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101df0 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101df0:	6a 00                	push   $0x0
  pushl $21
c0101df2:	6a 15                	push   $0x15
  jmp __alltraps
c0101df4:	e9 1f ff ff ff       	jmp    c0101d18 <__alltraps>

c0101df9 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101df9:	6a 00                	push   $0x0
  pushl $22
c0101dfb:	6a 16                	push   $0x16
  jmp __alltraps
c0101dfd:	e9 16 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101e02 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e02:	6a 00                	push   $0x0
  pushl $23
c0101e04:	6a 17                	push   $0x17
  jmp __alltraps
c0101e06:	e9 0d ff ff ff       	jmp    c0101d18 <__alltraps>

c0101e0b <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e0b:	6a 00                	push   $0x0
  pushl $24
c0101e0d:	6a 18                	push   $0x18
  jmp __alltraps
c0101e0f:	e9 04 ff ff ff       	jmp    c0101d18 <__alltraps>

c0101e14 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e14:	6a 00                	push   $0x0
  pushl $25
c0101e16:	6a 19                	push   $0x19
  jmp __alltraps
c0101e18:	e9 fb fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e1d <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e1d:	6a 00                	push   $0x0
  pushl $26
c0101e1f:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e21:	e9 f2 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e26 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e26:	6a 00                	push   $0x0
  pushl $27
c0101e28:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e2a:	e9 e9 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e2f <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e2f:	6a 00                	push   $0x0
  pushl $28
c0101e31:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101e33:	e9 e0 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e38 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101e38:	6a 00                	push   $0x0
  pushl $29
c0101e3a:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101e3c:	e9 d7 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e41 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101e41:	6a 00                	push   $0x0
  pushl $30
c0101e43:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101e45:	e9 ce fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e4a <vector31>:
.globl vector31
vector31:
  pushl $0
c0101e4a:	6a 00                	push   $0x0
  pushl $31
c0101e4c:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101e4e:	e9 c5 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e53 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101e53:	6a 00                	push   $0x0
  pushl $32
c0101e55:	6a 20                	push   $0x20
  jmp __alltraps
c0101e57:	e9 bc fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e5c <vector33>:
.globl vector33
vector33:
  pushl $0
c0101e5c:	6a 00                	push   $0x0
  pushl $33
c0101e5e:	6a 21                	push   $0x21
  jmp __alltraps
c0101e60:	e9 b3 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e65 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101e65:	6a 00                	push   $0x0
  pushl $34
c0101e67:	6a 22                	push   $0x22
  jmp __alltraps
c0101e69:	e9 aa fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e6e <vector35>:
.globl vector35
vector35:
  pushl $0
c0101e6e:	6a 00                	push   $0x0
  pushl $35
c0101e70:	6a 23                	push   $0x23
  jmp __alltraps
c0101e72:	e9 a1 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e77 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101e77:	6a 00                	push   $0x0
  pushl $36
c0101e79:	6a 24                	push   $0x24
  jmp __alltraps
c0101e7b:	e9 98 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e80 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101e80:	6a 00                	push   $0x0
  pushl $37
c0101e82:	6a 25                	push   $0x25
  jmp __alltraps
c0101e84:	e9 8f fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e89 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101e89:	6a 00                	push   $0x0
  pushl $38
c0101e8b:	6a 26                	push   $0x26
  jmp __alltraps
c0101e8d:	e9 86 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e92 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101e92:	6a 00                	push   $0x0
  pushl $39
c0101e94:	6a 27                	push   $0x27
  jmp __alltraps
c0101e96:	e9 7d fe ff ff       	jmp    c0101d18 <__alltraps>

c0101e9b <vector40>:
.globl vector40
vector40:
  pushl $0
c0101e9b:	6a 00                	push   $0x0
  pushl $40
c0101e9d:	6a 28                	push   $0x28
  jmp __alltraps
c0101e9f:	e9 74 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ea4 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101ea4:	6a 00                	push   $0x0
  pushl $41
c0101ea6:	6a 29                	push   $0x29
  jmp __alltraps
c0101ea8:	e9 6b fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ead <vector42>:
.globl vector42
vector42:
  pushl $0
c0101ead:	6a 00                	push   $0x0
  pushl $42
c0101eaf:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101eb1:	e9 62 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101eb6 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101eb6:	6a 00                	push   $0x0
  pushl $43
c0101eb8:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101eba:	e9 59 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ebf <vector44>:
.globl vector44
vector44:
  pushl $0
c0101ebf:	6a 00                	push   $0x0
  pushl $44
c0101ec1:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101ec3:	e9 50 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ec8 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101ec8:	6a 00                	push   $0x0
  pushl $45
c0101eca:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101ecc:	e9 47 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ed1 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101ed1:	6a 00                	push   $0x0
  pushl $46
c0101ed3:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101ed5:	e9 3e fe ff ff       	jmp    c0101d18 <__alltraps>

c0101eda <vector47>:
.globl vector47
vector47:
  pushl $0
c0101eda:	6a 00                	push   $0x0
  pushl $47
c0101edc:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101ede:	e9 35 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ee3 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101ee3:	6a 00                	push   $0x0
  pushl $48
c0101ee5:	6a 30                	push   $0x30
  jmp __alltraps
c0101ee7:	e9 2c fe ff ff       	jmp    c0101d18 <__alltraps>

c0101eec <vector49>:
.globl vector49
vector49:
  pushl $0
c0101eec:	6a 00                	push   $0x0
  pushl $49
c0101eee:	6a 31                	push   $0x31
  jmp __alltraps
c0101ef0:	e9 23 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101ef5 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101ef5:	6a 00                	push   $0x0
  pushl $50
c0101ef7:	6a 32                	push   $0x32
  jmp __alltraps
c0101ef9:	e9 1a fe ff ff       	jmp    c0101d18 <__alltraps>

c0101efe <vector51>:
.globl vector51
vector51:
  pushl $0
c0101efe:	6a 00                	push   $0x0
  pushl $51
c0101f00:	6a 33                	push   $0x33
  jmp __alltraps
c0101f02:	e9 11 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101f07 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f07:	6a 00                	push   $0x0
  pushl $52
c0101f09:	6a 34                	push   $0x34
  jmp __alltraps
c0101f0b:	e9 08 fe ff ff       	jmp    c0101d18 <__alltraps>

c0101f10 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f10:	6a 00                	push   $0x0
  pushl $53
c0101f12:	6a 35                	push   $0x35
  jmp __alltraps
c0101f14:	e9 ff fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f19 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f19:	6a 00                	push   $0x0
  pushl $54
c0101f1b:	6a 36                	push   $0x36
  jmp __alltraps
c0101f1d:	e9 f6 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f22 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f22:	6a 00                	push   $0x0
  pushl $55
c0101f24:	6a 37                	push   $0x37
  jmp __alltraps
c0101f26:	e9 ed fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f2b <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f2b:	6a 00                	push   $0x0
  pushl $56
c0101f2d:	6a 38                	push   $0x38
  jmp __alltraps
c0101f2f:	e9 e4 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f34 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101f34:	6a 00                	push   $0x0
  pushl $57
c0101f36:	6a 39                	push   $0x39
  jmp __alltraps
c0101f38:	e9 db fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f3d <vector58>:
.globl vector58
vector58:
  pushl $0
c0101f3d:	6a 00                	push   $0x0
  pushl $58
c0101f3f:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101f41:	e9 d2 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f46 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101f46:	6a 00                	push   $0x0
  pushl $59
c0101f48:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101f4a:	e9 c9 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f4f <vector60>:
.globl vector60
vector60:
  pushl $0
c0101f4f:	6a 00                	push   $0x0
  pushl $60
c0101f51:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101f53:	e9 c0 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f58 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101f58:	6a 00                	push   $0x0
  pushl $61
c0101f5a:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101f5c:	e9 b7 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f61 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101f61:	6a 00                	push   $0x0
  pushl $62
c0101f63:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101f65:	e9 ae fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f6a <vector63>:
.globl vector63
vector63:
  pushl $0
c0101f6a:	6a 00                	push   $0x0
  pushl $63
c0101f6c:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101f6e:	e9 a5 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f73 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101f73:	6a 00                	push   $0x0
  pushl $64
c0101f75:	6a 40                	push   $0x40
  jmp __alltraps
c0101f77:	e9 9c fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f7c <vector65>:
.globl vector65
vector65:
  pushl $0
c0101f7c:	6a 00                	push   $0x0
  pushl $65
c0101f7e:	6a 41                	push   $0x41
  jmp __alltraps
c0101f80:	e9 93 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f85 <vector66>:
.globl vector66
vector66:
  pushl $0
c0101f85:	6a 00                	push   $0x0
  pushl $66
c0101f87:	6a 42                	push   $0x42
  jmp __alltraps
c0101f89:	e9 8a fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f8e <vector67>:
.globl vector67
vector67:
  pushl $0
c0101f8e:	6a 00                	push   $0x0
  pushl $67
c0101f90:	6a 43                	push   $0x43
  jmp __alltraps
c0101f92:	e9 81 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101f97 <vector68>:
.globl vector68
vector68:
  pushl $0
c0101f97:	6a 00                	push   $0x0
  pushl $68
c0101f99:	6a 44                	push   $0x44
  jmp __alltraps
c0101f9b:	e9 78 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fa0 <vector69>:
.globl vector69
vector69:
  pushl $0
c0101fa0:	6a 00                	push   $0x0
  pushl $69
c0101fa2:	6a 45                	push   $0x45
  jmp __alltraps
c0101fa4:	e9 6f fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fa9 <vector70>:
.globl vector70
vector70:
  pushl $0
c0101fa9:	6a 00                	push   $0x0
  pushl $70
c0101fab:	6a 46                	push   $0x46
  jmp __alltraps
c0101fad:	e9 66 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fb2 <vector71>:
.globl vector71
vector71:
  pushl $0
c0101fb2:	6a 00                	push   $0x0
  pushl $71
c0101fb4:	6a 47                	push   $0x47
  jmp __alltraps
c0101fb6:	e9 5d fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fbb <vector72>:
.globl vector72
vector72:
  pushl $0
c0101fbb:	6a 00                	push   $0x0
  pushl $72
c0101fbd:	6a 48                	push   $0x48
  jmp __alltraps
c0101fbf:	e9 54 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fc4 <vector73>:
.globl vector73
vector73:
  pushl $0
c0101fc4:	6a 00                	push   $0x0
  pushl $73
c0101fc6:	6a 49                	push   $0x49
  jmp __alltraps
c0101fc8:	e9 4b fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fcd <vector74>:
.globl vector74
vector74:
  pushl $0
c0101fcd:	6a 00                	push   $0x0
  pushl $74
c0101fcf:	6a 4a                	push   $0x4a
  jmp __alltraps
c0101fd1:	e9 42 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fd6 <vector75>:
.globl vector75
vector75:
  pushl $0
c0101fd6:	6a 00                	push   $0x0
  pushl $75
c0101fd8:	6a 4b                	push   $0x4b
  jmp __alltraps
c0101fda:	e9 39 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fdf <vector76>:
.globl vector76
vector76:
  pushl $0
c0101fdf:	6a 00                	push   $0x0
  pushl $76
c0101fe1:	6a 4c                	push   $0x4c
  jmp __alltraps
c0101fe3:	e9 30 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101fe8 <vector77>:
.globl vector77
vector77:
  pushl $0
c0101fe8:	6a 00                	push   $0x0
  pushl $77
c0101fea:	6a 4d                	push   $0x4d
  jmp __alltraps
c0101fec:	e9 27 fd ff ff       	jmp    c0101d18 <__alltraps>

c0101ff1 <vector78>:
.globl vector78
vector78:
  pushl $0
c0101ff1:	6a 00                	push   $0x0
  pushl $78
c0101ff3:	6a 4e                	push   $0x4e
  jmp __alltraps
c0101ff5:	e9 1e fd ff ff       	jmp    c0101d18 <__alltraps>

c0101ffa <vector79>:
.globl vector79
vector79:
  pushl $0
c0101ffa:	6a 00                	push   $0x0
  pushl $79
c0101ffc:	6a 4f                	push   $0x4f
  jmp __alltraps
c0101ffe:	e9 15 fd ff ff       	jmp    c0101d18 <__alltraps>

c0102003 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102003:	6a 00                	push   $0x0
  pushl $80
c0102005:	6a 50                	push   $0x50
  jmp __alltraps
c0102007:	e9 0c fd ff ff       	jmp    c0101d18 <__alltraps>

c010200c <vector81>:
.globl vector81
vector81:
  pushl $0
c010200c:	6a 00                	push   $0x0
  pushl $81
c010200e:	6a 51                	push   $0x51
  jmp __alltraps
c0102010:	e9 03 fd ff ff       	jmp    c0101d18 <__alltraps>

c0102015 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102015:	6a 00                	push   $0x0
  pushl $82
c0102017:	6a 52                	push   $0x52
  jmp __alltraps
c0102019:	e9 fa fc ff ff       	jmp    c0101d18 <__alltraps>

c010201e <vector83>:
.globl vector83
vector83:
  pushl $0
c010201e:	6a 00                	push   $0x0
  pushl $83
c0102020:	6a 53                	push   $0x53
  jmp __alltraps
c0102022:	e9 f1 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102027 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102027:	6a 00                	push   $0x0
  pushl $84
c0102029:	6a 54                	push   $0x54
  jmp __alltraps
c010202b:	e9 e8 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102030 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102030:	6a 00                	push   $0x0
  pushl $85
c0102032:	6a 55                	push   $0x55
  jmp __alltraps
c0102034:	e9 df fc ff ff       	jmp    c0101d18 <__alltraps>

c0102039 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102039:	6a 00                	push   $0x0
  pushl $86
c010203b:	6a 56                	push   $0x56
  jmp __alltraps
c010203d:	e9 d6 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102042 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102042:	6a 00                	push   $0x0
  pushl $87
c0102044:	6a 57                	push   $0x57
  jmp __alltraps
c0102046:	e9 cd fc ff ff       	jmp    c0101d18 <__alltraps>

c010204b <vector88>:
.globl vector88
vector88:
  pushl $0
c010204b:	6a 00                	push   $0x0
  pushl $88
c010204d:	6a 58                	push   $0x58
  jmp __alltraps
c010204f:	e9 c4 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102054 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102054:	6a 00                	push   $0x0
  pushl $89
c0102056:	6a 59                	push   $0x59
  jmp __alltraps
c0102058:	e9 bb fc ff ff       	jmp    c0101d18 <__alltraps>

c010205d <vector90>:
.globl vector90
vector90:
  pushl $0
c010205d:	6a 00                	push   $0x0
  pushl $90
c010205f:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102061:	e9 b2 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102066 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102066:	6a 00                	push   $0x0
  pushl $91
c0102068:	6a 5b                	push   $0x5b
  jmp __alltraps
c010206a:	e9 a9 fc ff ff       	jmp    c0101d18 <__alltraps>

c010206f <vector92>:
.globl vector92
vector92:
  pushl $0
c010206f:	6a 00                	push   $0x0
  pushl $92
c0102071:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102073:	e9 a0 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102078 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102078:	6a 00                	push   $0x0
  pushl $93
c010207a:	6a 5d                	push   $0x5d
  jmp __alltraps
c010207c:	e9 97 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102081 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102081:	6a 00                	push   $0x0
  pushl $94
c0102083:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102085:	e9 8e fc ff ff       	jmp    c0101d18 <__alltraps>

c010208a <vector95>:
.globl vector95
vector95:
  pushl $0
c010208a:	6a 00                	push   $0x0
  pushl $95
c010208c:	6a 5f                	push   $0x5f
  jmp __alltraps
c010208e:	e9 85 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102093 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102093:	6a 00                	push   $0x0
  pushl $96
c0102095:	6a 60                	push   $0x60
  jmp __alltraps
c0102097:	e9 7c fc ff ff       	jmp    c0101d18 <__alltraps>

c010209c <vector97>:
.globl vector97
vector97:
  pushl $0
c010209c:	6a 00                	push   $0x0
  pushl $97
c010209e:	6a 61                	push   $0x61
  jmp __alltraps
c01020a0:	e9 73 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020a5 <vector98>:
.globl vector98
vector98:
  pushl $0
c01020a5:	6a 00                	push   $0x0
  pushl $98
c01020a7:	6a 62                	push   $0x62
  jmp __alltraps
c01020a9:	e9 6a fc ff ff       	jmp    c0101d18 <__alltraps>

c01020ae <vector99>:
.globl vector99
vector99:
  pushl $0
c01020ae:	6a 00                	push   $0x0
  pushl $99
c01020b0:	6a 63                	push   $0x63
  jmp __alltraps
c01020b2:	e9 61 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020b7 <vector100>:
.globl vector100
vector100:
  pushl $0
c01020b7:	6a 00                	push   $0x0
  pushl $100
c01020b9:	6a 64                	push   $0x64
  jmp __alltraps
c01020bb:	e9 58 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020c0 <vector101>:
.globl vector101
vector101:
  pushl $0
c01020c0:	6a 00                	push   $0x0
  pushl $101
c01020c2:	6a 65                	push   $0x65
  jmp __alltraps
c01020c4:	e9 4f fc ff ff       	jmp    c0101d18 <__alltraps>

c01020c9 <vector102>:
.globl vector102
vector102:
  pushl $0
c01020c9:	6a 00                	push   $0x0
  pushl $102
c01020cb:	6a 66                	push   $0x66
  jmp __alltraps
c01020cd:	e9 46 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020d2 <vector103>:
.globl vector103
vector103:
  pushl $0
c01020d2:	6a 00                	push   $0x0
  pushl $103
c01020d4:	6a 67                	push   $0x67
  jmp __alltraps
c01020d6:	e9 3d fc ff ff       	jmp    c0101d18 <__alltraps>

c01020db <vector104>:
.globl vector104
vector104:
  pushl $0
c01020db:	6a 00                	push   $0x0
  pushl $104
c01020dd:	6a 68                	push   $0x68
  jmp __alltraps
c01020df:	e9 34 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020e4 <vector105>:
.globl vector105
vector105:
  pushl $0
c01020e4:	6a 00                	push   $0x0
  pushl $105
c01020e6:	6a 69                	push   $0x69
  jmp __alltraps
c01020e8:	e9 2b fc ff ff       	jmp    c0101d18 <__alltraps>

c01020ed <vector106>:
.globl vector106
vector106:
  pushl $0
c01020ed:	6a 00                	push   $0x0
  pushl $106
c01020ef:	6a 6a                	push   $0x6a
  jmp __alltraps
c01020f1:	e9 22 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020f6 <vector107>:
.globl vector107
vector107:
  pushl $0
c01020f6:	6a 00                	push   $0x0
  pushl $107
c01020f8:	6a 6b                	push   $0x6b
  jmp __alltraps
c01020fa:	e9 19 fc ff ff       	jmp    c0101d18 <__alltraps>

c01020ff <vector108>:
.globl vector108
vector108:
  pushl $0
c01020ff:	6a 00                	push   $0x0
  pushl $108
c0102101:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102103:	e9 10 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102108 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102108:	6a 00                	push   $0x0
  pushl $109
c010210a:	6a 6d                	push   $0x6d
  jmp __alltraps
c010210c:	e9 07 fc ff ff       	jmp    c0101d18 <__alltraps>

c0102111 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102111:	6a 00                	push   $0x0
  pushl $110
c0102113:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102115:	e9 fe fb ff ff       	jmp    c0101d18 <__alltraps>

c010211a <vector111>:
.globl vector111
vector111:
  pushl $0
c010211a:	6a 00                	push   $0x0
  pushl $111
c010211c:	6a 6f                	push   $0x6f
  jmp __alltraps
c010211e:	e9 f5 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102123 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102123:	6a 00                	push   $0x0
  pushl $112
c0102125:	6a 70                	push   $0x70
  jmp __alltraps
c0102127:	e9 ec fb ff ff       	jmp    c0101d18 <__alltraps>

c010212c <vector113>:
.globl vector113
vector113:
  pushl $0
c010212c:	6a 00                	push   $0x0
  pushl $113
c010212e:	6a 71                	push   $0x71
  jmp __alltraps
c0102130:	e9 e3 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102135 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102135:	6a 00                	push   $0x0
  pushl $114
c0102137:	6a 72                	push   $0x72
  jmp __alltraps
c0102139:	e9 da fb ff ff       	jmp    c0101d18 <__alltraps>

c010213e <vector115>:
.globl vector115
vector115:
  pushl $0
c010213e:	6a 00                	push   $0x0
  pushl $115
c0102140:	6a 73                	push   $0x73
  jmp __alltraps
c0102142:	e9 d1 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102147 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102147:	6a 00                	push   $0x0
  pushl $116
c0102149:	6a 74                	push   $0x74
  jmp __alltraps
c010214b:	e9 c8 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102150 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102150:	6a 00                	push   $0x0
  pushl $117
c0102152:	6a 75                	push   $0x75
  jmp __alltraps
c0102154:	e9 bf fb ff ff       	jmp    c0101d18 <__alltraps>

c0102159 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102159:	6a 00                	push   $0x0
  pushl $118
c010215b:	6a 76                	push   $0x76
  jmp __alltraps
c010215d:	e9 b6 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102162 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102162:	6a 00                	push   $0x0
  pushl $119
c0102164:	6a 77                	push   $0x77
  jmp __alltraps
c0102166:	e9 ad fb ff ff       	jmp    c0101d18 <__alltraps>

c010216b <vector120>:
.globl vector120
vector120:
  pushl $0
c010216b:	6a 00                	push   $0x0
  pushl $120
c010216d:	6a 78                	push   $0x78
  jmp __alltraps
c010216f:	e9 a4 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102174 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102174:	6a 00                	push   $0x0
  pushl $121
c0102176:	6a 79                	push   $0x79
  jmp __alltraps
c0102178:	e9 9b fb ff ff       	jmp    c0101d18 <__alltraps>

c010217d <vector122>:
.globl vector122
vector122:
  pushl $0
c010217d:	6a 00                	push   $0x0
  pushl $122
c010217f:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102181:	e9 92 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102186 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102186:	6a 00                	push   $0x0
  pushl $123
c0102188:	6a 7b                	push   $0x7b
  jmp __alltraps
c010218a:	e9 89 fb ff ff       	jmp    c0101d18 <__alltraps>

c010218f <vector124>:
.globl vector124
vector124:
  pushl $0
c010218f:	6a 00                	push   $0x0
  pushl $124
c0102191:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102193:	e9 80 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102198 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102198:	6a 00                	push   $0x0
  pushl $125
c010219a:	6a 7d                	push   $0x7d
  jmp __alltraps
c010219c:	e9 77 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021a1 <vector126>:
.globl vector126
vector126:
  pushl $0
c01021a1:	6a 00                	push   $0x0
  pushl $126
c01021a3:	6a 7e                	push   $0x7e
  jmp __alltraps
c01021a5:	e9 6e fb ff ff       	jmp    c0101d18 <__alltraps>

c01021aa <vector127>:
.globl vector127
vector127:
  pushl $0
c01021aa:	6a 00                	push   $0x0
  pushl $127
c01021ac:	6a 7f                	push   $0x7f
  jmp __alltraps
c01021ae:	e9 65 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021b3 <vector128>:
.globl vector128
vector128:
  pushl $0
c01021b3:	6a 00                	push   $0x0
  pushl $128
c01021b5:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01021ba:	e9 59 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021bf <vector129>:
.globl vector129
vector129:
  pushl $0
c01021bf:	6a 00                	push   $0x0
  pushl $129
c01021c1:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01021c6:	e9 4d fb ff ff       	jmp    c0101d18 <__alltraps>

c01021cb <vector130>:
.globl vector130
vector130:
  pushl $0
c01021cb:	6a 00                	push   $0x0
  pushl $130
c01021cd:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01021d2:	e9 41 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021d7 <vector131>:
.globl vector131
vector131:
  pushl $0
c01021d7:	6a 00                	push   $0x0
  pushl $131
c01021d9:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01021de:	e9 35 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021e3 <vector132>:
.globl vector132
vector132:
  pushl $0
c01021e3:	6a 00                	push   $0x0
  pushl $132
c01021e5:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01021ea:	e9 29 fb ff ff       	jmp    c0101d18 <__alltraps>

c01021ef <vector133>:
.globl vector133
vector133:
  pushl $0
c01021ef:	6a 00                	push   $0x0
  pushl $133
c01021f1:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01021f6:	e9 1d fb ff ff       	jmp    c0101d18 <__alltraps>

c01021fb <vector134>:
.globl vector134
vector134:
  pushl $0
c01021fb:	6a 00                	push   $0x0
  pushl $134
c01021fd:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102202:	e9 11 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102207 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102207:	6a 00                	push   $0x0
  pushl $135
c0102209:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010220e:	e9 05 fb ff ff       	jmp    c0101d18 <__alltraps>

c0102213 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $136
c0102215:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010221a:	e9 f9 fa ff ff       	jmp    c0101d18 <__alltraps>

c010221f <vector137>:
.globl vector137
vector137:
  pushl $0
c010221f:	6a 00                	push   $0x0
  pushl $137
c0102221:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102226:	e9 ed fa ff ff       	jmp    c0101d18 <__alltraps>

c010222b <vector138>:
.globl vector138
vector138:
  pushl $0
c010222b:	6a 00                	push   $0x0
  pushl $138
c010222d:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102232:	e9 e1 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102237 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $139
c0102239:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010223e:	e9 d5 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102243 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102243:	6a 00                	push   $0x0
  pushl $140
c0102245:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010224a:	e9 c9 fa ff ff       	jmp    c0101d18 <__alltraps>

c010224f <vector141>:
.globl vector141
vector141:
  pushl $0
c010224f:	6a 00                	push   $0x0
  pushl $141
c0102251:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102256:	e9 bd fa ff ff       	jmp    c0101d18 <__alltraps>

c010225b <vector142>:
.globl vector142
vector142:
  pushl $0
c010225b:	6a 00                	push   $0x0
  pushl $142
c010225d:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102262:	e9 b1 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102267 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102267:	6a 00                	push   $0x0
  pushl $143
c0102269:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010226e:	e9 a5 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102273 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102273:	6a 00                	push   $0x0
  pushl $144
c0102275:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010227a:	e9 99 fa ff ff       	jmp    c0101d18 <__alltraps>

c010227f <vector145>:
.globl vector145
vector145:
  pushl $0
c010227f:	6a 00                	push   $0x0
  pushl $145
c0102281:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102286:	e9 8d fa ff ff       	jmp    c0101d18 <__alltraps>

c010228b <vector146>:
.globl vector146
vector146:
  pushl $0
c010228b:	6a 00                	push   $0x0
  pushl $146
c010228d:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102292:	e9 81 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102297 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102297:	6a 00                	push   $0x0
  pushl $147
c0102299:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010229e:	e9 75 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022a3 <vector148>:
.globl vector148
vector148:
  pushl $0
c01022a3:	6a 00                	push   $0x0
  pushl $148
c01022a5:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01022aa:	e9 69 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022af <vector149>:
.globl vector149
vector149:
  pushl $0
c01022af:	6a 00                	push   $0x0
  pushl $149
c01022b1:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01022b6:	e9 5d fa ff ff       	jmp    c0101d18 <__alltraps>

c01022bb <vector150>:
.globl vector150
vector150:
  pushl $0
c01022bb:	6a 00                	push   $0x0
  pushl $150
c01022bd:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01022c2:	e9 51 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022c7 <vector151>:
.globl vector151
vector151:
  pushl $0
c01022c7:	6a 00                	push   $0x0
  pushl $151
c01022c9:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01022ce:	e9 45 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022d3 <vector152>:
.globl vector152
vector152:
  pushl $0
c01022d3:	6a 00                	push   $0x0
  pushl $152
c01022d5:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01022da:	e9 39 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022df <vector153>:
.globl vector153
vector153:
  pushl $0
c01022df:	6a 00                	push   $0x0
  pushl $153
c01022e1:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01022e6:	e9 2d fa ff ff       	jmp    c0101d18 <__alltraps>

c01022eb <vector154>:
.globl vector154
vector154:
  pushl $0
c01022eb:	6a 00                	push   $0x0
  pushl $154
c01022ed:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01022f2:	e9 21 fa ff ff       	jmp    c0101d18 <__alltraps>

c01022f7 <vector155>:
.globl vector155
vector155:
  pushl $0
c01022f7:	6a 00                	push   $0x0
  pushl $155
c01022f9:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01022fe:	e9 15 fa ff ff       	jmp    c0101d18 <__alltraps>

c0102303 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102303:	6a 00                	push   $0x0
  pushl $156
c0102305:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010230a:	e9 09 fa ff ff       	jmp    c0101d18 <__alltraps>

c010230f <vector157>:
.globl vector157
vector157:
  pushl $0
c010230f:	6a 00                	push   $0x0
  pushl $157
c0102311:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102316:	e9 fd f9 ff ff       	jmp    c0101d18 <__alltraps>

c010231b <vector158>:
.globl vector158
vector158:
  pushl $0
c010231b:	6a 00                	push   $0x0
  pushl $158
c010231d:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102322:	e9 f1 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102327 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102327:	6a 00                	push   $0x0
  pushl $159
c0102329:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010232e:	e9 e5 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102333 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102333:	6a 00                	push   $0x0
  pushl $160
c0102335:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010233a:	e9 d9 f9 ff ff       	jmp    c0101d18 <__alltraps>

c010233f <vector161>:
.globl vector161
vector161:
  pushl $0
c010233f:	6a 00                	push   $0x0
  pushl $161
c0102341:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102346:	e9 cd f9 ff ff       	jmp    c0101d18 <__alltraps>

c010234b <vector162>:
.globl vector162
vector162:
  pushl $0
c010234b:	6a 00                	push   $0x0
  pushl $162
c010234d:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102352:	e9 c1 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102357 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $163
c0102359:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010235e:	e9 b5 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102363 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102363:	6a 00                	push   $0x0
  pushl $164
c0102365:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010236a:	e9 a9 f9 ff ff       	jmp    c0101d18 <__alltraps>

c010236f <vector165>:
.globl vector165
vector165:
  pushl $0
c010236f:	6a 00                	push   $0x0
  pushl $165
c0102371:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102376:	e9 9d f9 ff ff       	jmp    c0101d18 <__alltraps>

c010237b <vector166>:
.globl vector166
vector166:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $166
c010237d:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102382:	e9 91 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102387 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102387:	6a 00                	push   $0x0
  pushl $167
c0102389:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010238e:	e9 85 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102393 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102393:	6a 00                	push   $0x0
  pushl $168
c0102395:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010239a:	e9 79 f9 ff ff       	jmp    c0101d18 <__alltraps>

c010239f <vector169>:
.globl vector169
vector169:
  pushl $0
c010239f:	6a 00                	push   $0x0
  pushl $169
c01023a1:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01023a6:	e9 6d f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023ab <vector170>:
.globl vector170
vector170:
  pushl $0
c01023ab:	6a 00                	push   $0x0
  pushl $170
c01023ad:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01023b2:	e9 61 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023b7 <vector171>:
.globl vector171
vector171:
  pushl $0
c01023b7:	6a 00                	push   $0x0
  pushl $171
c01023b9:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01023be:	e9 55 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023c3 <vector172>:
.globl vector172
vector172:
  pushl $0
c01023c3:	6a 00                	push   $0x0
  pushl $172
c01023c5:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01023ca:	e9 49 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023cf <vector173>:
.globl vector173
vector173:
  pushl $0
c01023cf:	6a 00                	push   $0x0
  pushl $173
c01023d1:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01023d6:	e9 3d f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023db <vector174>:
.globl vector174
vector174:
  pushl $0
c01023db:	6a 00                	push   $0x0
  pushl $174
c01023dd:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01023e2:	e9 31 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023e7 <vector175>:
.globl vector175
vector175:
  pushl $0
c01023e7:	6a 00                	push   $0x0
  pushl $175
c01023e9:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01023ee:	e9 25 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023f3 <vector176>:
.globl vector176
vector176:
  pushl $0
c01023f3:	6a 00                	push   $0x0
  pushl $176
c01023f5:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01023fa:	e9 19 f9 ff ff       	jmp    c0101d18 <__alltraps>

c01023ff <vector177>:
.globl vector177
vector177:
  pushl $0
c01023ff:	6a 00                	push   $0x0
  pushl $177
c0102401:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102406:	e9 0d f9 ff ff       	jmp    c0101d18 <__alltraps>

c010240b <vector178>:
.globl vector178
vector178:
  pushl $0
c010240b:	6a 00                	push   $0x0
  pushl $178
c010240d:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102412:	e9 01 f9 ff ff       	jmp    c0101d18 <__alltraps>

c0102417 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102417:	6a 00                	push   $0x0
  pushl $179
c0102419:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010241e:	e9 f5 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102423 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102423:	6a 00                	push   $0x0
  pushl $180
c0102425:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010242a:	e9 e9 f8 ff ff       	jmp    c0101d18 <__alltraps>

c010242f <vector181>:
.globl vector181
vector181:
  pushl $0
c010242f:	6a 00                	push   $0x0
  pushl $181
c0102431:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102436:	e9 dd f8 ff ff       	jmp    c0101d18 <__alltraps>

c010243b <vector182>:
.globl vector182
vector182:
  pushl $0
c010243b:	6a 00                	push   $0x0
  pushl $182
c010243d:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102442:	e9 d1 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102447 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102447:	6a 00                	push   $0x0
  pushl $183
c0102449:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010244e:	e9 c5 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102453 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102453:	6a 00                	push   $0x0
  pushl $184
c0102455:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010245a:	e9 b9 f8 ff ff       	jmp    c0101d18 <__alltraps>

c010245f <vector185>:
.globl vector185
vector185:
  pushl $0
c010245f:	6a 00                	push   $0x0
  pushl $185
c0102461:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102466:	e9 ad f8 ff ff       	jmp    c0101d18 <__alltraps>

c010246b <vector186>:
.globl vector186
vector186:
  pushl $0
c010246b:	6a 00                	push   $0x0
  pushl $186
c010246d:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102472:	e9 a1 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102477 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102477:	6a 00                	push   $0x0
  pushl $187
c0102479:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010247e:	e9 95 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102483 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102483:	6a 00                	push   $0x0
  pushl $188
c0102485:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010248a:	e9 89 f8 ff ff       	jmp    c0101d18 <__alltraps>

c010248f <vector189>:
.globl vector189
vector189:
  pushl $0
c010248f:	6a 00                	push   $0x0
  pushl $189
c0102491:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102496:	e9 7d f8 ff ff       	jmp    c0101d18 <__alltraps>

c010249b <vector190>:
.globl vector190
vector190:
  pushl $0
c010249b:	6a 00                	push   $0x0
  pushl $190
c010249d:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01024a2:	e9 71 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024a7 <vector191>:
.globl vector191
vector191:
  pushl $0
c01024a7:	6a 00                	push   $0x0
  pushl $191
c01024a9:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01024ae:	e9 65 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024b3 <vector192>:
.globl vector192
vector192:
  pushl $0
c01024b3:	6a 00                	push   $0x0
  pushl $192
c01024b5:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01024ba:	e9 59 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024bf <vector193>:
.globl vector193
vector193:
  pushl $0
c01024bf:	6a 00                	push   $0x0
  pushl $193
c01024c1:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01024c6:	e9 4d f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024cb <vector194>:
.globl vector194
vector194:
  pushl $0
c01024cb:	6a 00                	push   $0x0
  pushl $194
c01024cd:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01024d2:	e9 41 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024d7 <vector195>:
.globl vector195
vector195:
  pushl $0
c01024d7:	6a 00                	push   $0x0
  pushl $195
c01024d9:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01024de:	e9 35 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024e3 <vector196>:
.globl vector196
vector196:
  pushl $0
c01024e3:	6a 00                	push   $0x0
  pushl $196
c01024e5:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01024ea:	e9 29 f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024ef <vector197>:
.globl vector197
vector197:
  pushl $0
c01024ef:	6a 00                	push   $0x0
  pushl $197
c01024f1:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01024f6:	e9 1d f8 ff ff       	jmp    c0101d18 <__alltraps>

c01024fb <vector198>:
.globl vector198
vector198:
  pushl $0
c01024fb:	6a 00                	push   $0x0
  pushl $198
c01024fd:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102502:	e9 11 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102507 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102507:	6a 00                	push   $0x0
  pushl $199
c0102509:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010250e:	e9 05 f8 ff ff       	jmp    c0101d18 <__alltraps>

c0102513 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102513:	6a 00                	push   $0x0
  pushl $200
c0102515:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010251a:	e9 f9 f7 ff ff       	jmp    c0101d18 <__alltraps>

c010251f <vector201>:
.globl vector201
vector201:
  pushl $0
c010251f:	6a 00                	push   $0x0
  pushl $201
c0102521:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102526:	e9 ed f7 ff ff       	jmp    c0101d18 <__alltraps>

c010252b <vector202>:
.globl vector202
vector202:
  pushl $0
c010252b:	6a 00                	push   $0x0
  pushl $202
c010252d:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102532:	e9 e1 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102537 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102537:	6a 00                	push   $0x0
  pushl $203
c0102539:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010253e:	e9 d5 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102543 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102543:	6a 00                	push   $0x0
  pushl $204
c0102545:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010254a:	e9 c9 f7 ff ff       	jmp    c0101d18 <__alltraps>

c010254f <vector205>:
.globl vector205
vector205:
  pushl $0
c010254f:	6a 00                	push   $0x0
  pushl $205
c0102551:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102556:	e9 bd f7 ff ff       	jmp    c0101d18 <__alltraps>

c010255b <vector206>:
.globl vector206
vector206:
  pushl $0
c010255b:	6a 00                	push   $0x0
  pushl $206
c010255d:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102562:	e9 b1 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102567 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102567:	6a 00                	push   $0x0
  pushl $207
c0102569:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010256e:	e9 a5 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102573 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102573:	6a 00                	push   $0x0
  pushl $208
c0102575:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010257a:	e9 99 f7 ff ff       	jmp    c0101d18 <__alltraps>

c010257f <vector209>:
.globl vector209
vector209:
  pushl $0
c010257f:	6a 00                	push   $0x0
  pushl $209
c0102581:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102586:	e9 8d f7 ff ff       	jmp    c0101d18 <__alltraps>

c010258b <vector210>:
.globl vector210
vector210:
  pushl $0
c010258b:	6a 00                	push   $0x0
  pushl $210
c010258d:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102592:	e9 81 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102597 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102597:	6a 00                	push   $0x0
  pushl $211
c0102599:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010259e:	e9 75 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025a3 <vector212>:
.globl vector212
vector212:
  pushl $0
c01025a3:	6a 00                	push   $0x0
  pushl $212
c01025a5:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01025aa:	e9 69 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025af <vector213>:
.globl vector213
vector213:
  pushl $0
c01025af:	6a 00                	push   $0x0
  pushl $213
c01025b1:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01025b6:	e9 5d f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025bb <vector214>:
.globl vector214
vector214:
  pushl $0
c01025bb:	6a 00                	push   $0x0
  pushl $214
c01025bd:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01025c2:	e9 51 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025c7 <vector215>:
.globl vector215
vector215:
  pushl $0
c01025c7:	6a 00                	push   $0x0
  pushl $215
c01025c9:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01025ce:	e9 45 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025d3 <vector216>:
.globl vector216
vector216:
  pushl $0
c01025d3:	6a 00                	push   $0x0
  pushl $216
c01025d5:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01025da:	e9 39 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025df <vector217>:
.globl vector217
vector217:
  pushl $0
c01025df:	6a 00                	push   $0x0
  pushl $217
c01025e1:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01025e6:	e9 2d f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025eb <vector218>:
.globl vector218
vector218:
  pushl $0
c01025eb:	6a 00                	push   $0x0
  pushl $218
c01025ed:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01025f2:	e9 21 f7 ff ff       	jmp    c0101d18 <__alltraps>

c01025f7 <vector219>:
.globl vector219
vector219:
  pushl $0
c01025f7:	6a 00                	push   $0x0
  pushl $219
c01025f9:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01025fe:	e9 15 f7 ff ff       	jmp    c0101d18 <__alltraps>

c0102603 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102603:	6a 00                	push   $0x0
  pushl $220
c0102605:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010260a:	e9 09 f7 ff ff       	jmp    c0101d18 <__alltraps>

c010260f <vector221>:
.globl vector221
vector221:
  pushl $0
c010260f:	6a 00                	push   $0x0
  pushl $221
c0102611:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102616:	e9 fd f6 ff ff       	jmp    c0101d18 <__alltraps>

c010261b <vector222>:
.globl vector222
vector222:
  pushl $0
c010261b:	6a 00                	push   $0x0
  pushl $222
c010261d:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102622:	e9 f1 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102627 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102627:	6a 00                	push   $0x0
  pushl $223
c0102629:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010262e:	e9 e5 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102633 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102633:	6a 00                	push   $0x0
  pushl $224
c0102635:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010263a:	e9 d9 f6 ff ff       	jmp    c0101d18 <__alltraps>

c010263f <vector225>:
.globl vector225
vector225:
  pushl $0
c010263f:	6a 00                	push   $0x0
  pushl $225
c0102641:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102646:	e9 cd f6 ff ff       	jmp    c0101d18 <__alltraps>

c010264b <vector226>:
.globl vector226
vector226:
  pushl $0
c010264b:	6a 00                	push   $0x0
  pushl $226
c010264d:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102652:	e9 c1 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102657 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102657:	6a 00                	push   $0x0
  pushl $227
c0102659:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010265e:	e9 b5 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102663 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102663:	6a 00                	push   $0x0
  pushl $228
c0102665:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010266a:	e9 a9 f6 ff ff       	jmp    c0101d18 <__alltraps>

c010266f <vector229>:
.globl vector229
vector229:
  pushl $0
c010266f:	6a 00                	push   $0x0
  pushl $229
c0102671:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102676:	e9 9d f6 ff ff       	jmp    c0101d18 <__alltraps>

c010267b <vector230>:
.globl vector230
vector230:
  pushl $0
c010267b:	6a 00                	push   $0x0
  pushl $230
c010267d:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102682:	e9 91 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102687 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102687:	6a 00                	push   $0x0
  pushl $231
c0102689:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010268e:	e9 85 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102693 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102693:	6a 00                	push   $0x0
  pushl $232
c0102695:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010269a:	e9 79 f6 ff ff       	jmp    c0101d18 <__alltraps>

c010269f <vector233>:
.globl vector233
vector233:
  pushl $0
c010269f:	6a 00                	push   $0x0
  pushl $233
c01026a1:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01026a6:	e9 6d f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026ab <vector234>:
.globl vector234
vector234:
  pushl $0
c01026ab:	6a 00                	push   $0x0
  pushl $234
c01026ad:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01026b2:	e9 61 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026b7 <vector235>:
.globl vector235
vector235:
  pushl $0
c01026b7:	6a 00                	push   $0x0
  pushl $235
c01026b9:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01026be:	e9 55 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026c3 <vector236>:
.globl vector236
vector236:
  pushl $0
c01026c3:	6a 00                	push   $0x0
  pushl $236
c01026c5:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01026ca:	e9 49 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026cf <vector237>:
.globl vector237
vector237:
  pushl $0
c01026cf:	6a 00                	push   $0x0
  pushl $237
c01026d1:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01026d6:	e9 3d f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026db <vector238>:
.globl vector238
vector238:
  pushl $0
c01026db:	6a 00                	push   $0x0
  pushl $238
c01026dd:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01026e2:	e9 31 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026e7 <vector239>:
.globl vector239
vector239:
  pushl $0
c01026e7:	6a 00                	push   $0x0
  pushl $239
c01026e9:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01026ee:	e9 25 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026f3 <vector240>:
.globl vector240
vector240:
  pushl $0
c01026f3:	6a 00                	push   $0x0
  pushl $240
c01026f5:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01026fa:	e9 19 f6 ff ff       	jmp    c0101d18 <__alltraps>

c01026ff <vector241>:
.globl vector241
vector241:
  pushl $0
c01026ff:	6a 00                	push   $0x0
  pushl $241
c0102701:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102706:	e9 0d f6 ff ff       	jmp    c0101d18 <__alltraps>

c010270b <vector242>:
.globl vector242
vector242:
  pushl $0
c010270b:	6a 00                	push   $0x0
  pushl $242
c010270d:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102712:	e9 01 f6 ff ff       	jmp    c0101d18 <__alltraps>

c0102717 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102717:	6a 00                	push   $0x0
  pushl $243
c0102719:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010271e:	e9 f5 f5 ff ff       	jmp    c0101d18 <__alltraps>

c0102723 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102723:	6a 00                	push   $0x0
  pushl $244
c0102725:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010272a:	e9 e9 f5 ff ff       	jmp    c0101d18 <__alltraps>

c010272f <vector245>:
.globl vector245
vector245:
  pushl $0
c010272f:	6a 00                	push   $0x0
  pushl $245
c0102731:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102736:	e9 dd f5 ff ff       	jmp    c0101d18 <__alltraps>

c010273b <vector246>:
.globl vector246
vector246:
  pushl $0
c010273b:	6a 00                	push   $0x0
  pushl $246
c010273d:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102742:	e9 d1 f5 ff ff       	jmp    c0101d18 <__alltraps>

c0102747 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102747:	6a 00                	push   $0x0
  pushl $247
c0102749:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010274e:	e9 c5 f5 ff ff       	jmp    c0101d18 <__alltraps>

c0102753 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102753:	6a 00                	push   $0x0
  pushl $248
c0102755:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010275a:	e9 b9 f5 ff ff       	jmp    c0101d18 <__alltraps>

c010275f <vector249>:
.globl vector249
vector249:
  pushl $0
c010275f:	6a 00                	push   $0x0
  pushl $249
c0102761:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102766:	e9 ad f5 ff ff       	jmp    c0101d18 <__alltraps>

c010276b <vector250>:
.globl vector250
vector250:
  pushl $0
c010276b:	6a 00                	push   $0x0
  pushl $250
c010276d:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102772:	e9 a1 f5 ff ff       	jmp    c0101d18 <__alltraps>

c0102777 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102777:	6a 00                	push   $0x0
  pushl $251
c0102779:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010277e:	e9 95 f5 ff ff       	jmp    c0101d18 <__alltraps>

c0102783 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102783:	6a 00                	push   $0x0
  pushl $252
c0102785:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010278a:	e9 89 f5 ff ff       	jmp    c0101d18 <__alltraps>

c010278f <vector253>:
.globl vector253
vector253:
  pushl $0
c010278f:	6a 00                	push   $0x0
  pushl $253
c0102791:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102796:	e9 7d f5 ff ff       	jmp    c0101d18 <__alltraps>

c010279b <vector254>:
.globl vector254
vector254:
  pushl $0
c010279b:	6a 00                	push   $0x0
  pushl $254
c010279d:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01027a2:	e9 71 f5 ff ff       	jmp    c0101d18 <__alltraps>

c01027a7 <vector255>:
.globl vector255
vector255:
  pushl $0
c01027a7:	6a 00                	push   $0x0
  pushl $255
c01027a9:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01027ae:	e9 65 f5 ff ff       	jmp    c0101d18 <__alltraps>

c01027b3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01027b3:	55                   	push   %ebp
c01027b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01027b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01027b9:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c01027be:	29 c2                	sub    %eax,%edx
c01027c0:	89 d0                	mov    %edx,%eax
c01027c2:	c1 f8 05             	sar    $0x5,%eax
}
c01027c5:	5d                   	pop    %ebp
c01027c6:	c3                   	ret    

c01027c7 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01027c7:	55                   	push   %ebp
c01027c8:	89 e5                	mov    %esp,%ebp
c01027ca:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01027cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01027d0:	89 04 24             	mov    %eax,(%esp)
c01027d3:	e8 db ff ff ff       	call   c01027b3 <page2ppn>
c01027d8:	c1 e0 0c             	shl    $0xc,%eax
}
c01027db:	c9                   	leave  
c01027dc:	c3                   	ret    

c01027dd <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01027dd:	55                   	push   %ebp
c01027de:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01027e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e3:	8b 00                	mov    (%eax),%eax
}
c01027e5:	5d                   	pop    %ebp
c01027e6:	c3                   	ret    

c01027e7 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01027e7:	55                   	push   %ebp
c01027e8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01027ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ed:	8b 55 0c             	mov    0xc(%ebp),%edx
c01027f0:	89 10                	mov    %edx,(%eax)
}
c01027f2:	5d                   	pop    %ebp
c01027f3:	c3                   	ret    

c01027f4 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01027f4:	55                   	push   %ebp
c01027f5:	89 e5                	mov    %esp,%ebp
c01027f7:	83 ec 10             	sub    $0x10,%esp
c01027fa:	c7 45 fc b8 d9 11 c0 	movl   $0xc011d9b8,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102801:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102804:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102807:	89 50 04             	mov    %edx,0x4(%eax)
c010280a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010280d:	8b 50 04             	mov    0x4(%eax),%edx
c0102810:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102813:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0102815:	c7 05 c0 d9 11 c0 00 	movl   $0x0,0xc011d9c0
c010281c:	00 00 00 
}
c010281f:	c9                   	leave  
c0102820:	c3                   	ret    

c0102821 <dump_list>:

static void
dump_list() {
c0102821:	55                   	push   %ebp
c0102822:	89 e5                	mov    %esp,%ebp
c0102824:	83 ec 28             	sub    $0x28,%esp
    // check order
    list_entry_t *le = &free_list;
c0102827:	c7 45 f4 b8 d9 11 c0 	movl   $0xc011d9b8,-0xc(%ebp)
    cprintf("Start list dump:\n");
c010282e:	c7 04 24 50 79 10 c0 	movl   $0xc0107950,(%esp)
c0102835:	e8 8d d9 ff ff       	call   c01001c7 <cprintf>
    while ((le = list_next(le)) != &free_list) {
c010283a:	eb 26                	jmp    c0102862 <dump_list+0x41>
        struct Page *p = le2page(le, page_link);
c010283c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010283f:	83 e8 0c             	sub    $0xc,%eax
c0102842:	89 45 f0             	mov    %eax,-0x10(%ebp)
        cprintf("Page %x property %d\n", p, p->property);
c0102845:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102848:	8b 40 08             	mov    0x8(%eax),%eax
c010284b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010284f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102852:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102856:	c7 04 24 62 79 10 c0 	movl   $0xc0107962,(%esp)
c010285d:	e8 65 d9 ff ff       	call   c01001c7 <cprintf>
c0102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102865:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102868:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010286b:	8b 40 04             	mov    0x4(%eax),%eax
static void
dump_list() {
    // check order
    list_entry_t *le = &free_list;
    cprintf("Start list dump:\n");
    while ((le = list_next(le)) != &free_list) {
c010286e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102871:	81 7d f4 b8 d9 11 c0 	cmpl   $0xc011d9b8,-0xc(%ebp)
c0102878:	75 c2                	jne    c010283c <dump_list+0x1b>
        struct Page *p = le2page(le, page_link);
        cprintf("Page %x property %d\n", p, p->property);
    }
}
c010287a:	c9                   	leave  
c010287b:	c3                   	ret    

c010287c <check_order>:

static void
check_order() {
c010287c:	55                   	push   %ebp
c010287d:	89 e5                	mov    %esp,%ebp
c010287f:	83 ec 38             	sub    $0x38,%esp
    // check order
    list_entry_t *le = &free_list;
c0102882:	c7 45 f4 b8 d9 11 c0 	movl   $0xc011d9b8,-0xc(%ebp)
    struct Page *before = NULL;
c0102889:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102890:	eb 78                	jmp    c010290a <check_order+0x8e>
        struct Page *p = le2page(le, page_link);
c0102892:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102895:	83 e8 0c             	sub    $0xc,%eax
c0102898:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (before != NULL)
c010289b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010289f:	74 63                	je     c0102904 <check_order+0x88>
            if (before + before->property > p) {
c01028a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028a4:	8b 40 08             	mov    0x8(%eax),%eax
c01028a7:	c1 e0 05             	shl    $0x5,%eax
c01028aa:	89 c2                	mov    %eax,%edx
c01028ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028af:	01 d0                	add    %edx,%eax
c01028b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01028b4:	76 4e                	jbe    c0102904 <check_order+0x88>
                dump_list();
c01028b6:	e8 66 ff ff ff       	call   c0102821 <dump_list>
                panic("Warning: disordered %x+%d=%x > %x\n",
c01028bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028be:	8b 40 08             	mov    0x8(%eax),%eax
c01028c1:	c1 e0 05             	shl    $0x5,%eax
c01028c4:	89 c2                	mov    %eax,%edx
c01028c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028c9:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
c01028cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028cf:	8b 40 08             	mov    0x8(%eax),%eax
c01028d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01028d5:	89 54 24 18          	mov    %edx,0x18(%esp)
c01028d9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01028dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01028e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01028e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028e8:	c7 44 24 08 78 79 10 	movl   $0xc0107978,0x8(%esp)
c01028ef:	c0 
c01028f0:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01028f7:	00 
c01028f8:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01028ff:	e8 59 e2 ff ff       	call   c0100b5d <__panic>
                        before, before->property,
                        before + before->property, p);
                return ;
            }
        before = p;
c0102904:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102907:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010290d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102910:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102913:	8b 40 04             	mov    0x4(%eax),%eax
static void
check_order() {
    // check order
    list_entry_t *le = &free_list;
    struct Page *before = NULL;
    while ((le = list_next(le)) != &free_list) {
c0102916:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102919:	81 7d f4 b8 d9 11 c0 	cmpl   $0xc011d9b8,-0xc(%ebp)
c0102920:	0f 85 6c ff ff ff    	jne    c0102892 <check_order+0x16>
                        before + before->property, p);
                return ;
            }
        before = p;
    }
}
c0102926:	c9                   	leave  
c0102927:	c3                   	ret    

c0102928 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102928:	55                   	push   %ebp
c0102929:	89 e5                	mov    %esp,%ebp
c010292b:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010292e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102932:	75 24                	jne    c0102958 <default_init_memmap+0x30>
c0102934:	c7 44 24 0c b1 79 10 	movl   $0xc01079b1,0xc(%esp)
c010293b:	c0 
c010293c:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0102943:	c0 
c0102944:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010294b:	00 
c010294c:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0102953:	e8 05 e2 ff ff       	call   c0100b5d <__panic>
    struct Page *p = base;
c0102958:	8b 45 08             	mov    0x8(%ebp),%eax
c010295b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010295e:	eb 7d                	jmp    c01029dd <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102960:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102963:	83 c0 04             	add    $0x4,%eax
c0102966:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010296d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102970:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102973:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102976:	0f a3 10             	bt     %edx,(%eax)
c0102979:	19 c0                	sbb    %eax,%eax
c010297b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010297e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102982:	0f 95 c0             	setne  %al
c0102985:	0f b6 c0             	movzbl %al,%eax
c0102988:	85 c0                	test   %eax,%eax
c010298a:	75 24                	jne    c01029b0 <default_init_memmap+0x88>
c010298c:	c7 44 24 0c cc 79 10 	movl   $0xc01079cc,0xc(%esp)
c0102993:	c0 
c0102994:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c010299b:	c0 
c010299c:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01029a3:	00 
c01029a4:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01029ab:	e8 ad e1 ff ff       	call   c0100b5d <__panic>
        p->flags = p->property = 0;
c01029b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01029ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029bd:	8b 50 08             	mov    0x8(%eax),%edx
c01029c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029c3:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01029c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01029cd:	00 
c01029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029d1:	89 04 24             	mov    %eax,(%esp)
c01029d4:	e8 0e fe ff ff       	call   c01027e7 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01029d9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01029dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029e0:	c1 e0 05             	shl    $0x5,%eax
c01029e3:	89 c2                	mov    %eax,%edx
c01029e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e8:	01 d0                	add    %edx,%eax
c01029ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029ed:	0f 85 6d ff ff ff    	jne    c0102960 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01029f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029f9:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01029fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ff:	83 c0 04             	add    $0x4,%eax
c0102a02:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102a09:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a12:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0102a15:	8b 15 c0 d9 11 c0    	mov    0xc011d9c0,%edx
c0102a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a1e:	01 d0                	add    %edx,%eax
c0102a20:	a3 c0 d9 11 c0       	mov    %eax,0xc011d9c0
    list_add_after(&free_list, &(base->page_link));
c0102a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a28:	83 c0 0c             	add    $0xc,%eax
c0102a2b:	c7 45 dc b8 d9 11 c0 	movl   $0xc011d9b8,-0x24(%ebp)
c0102a32:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102a35:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a38:	8b 40 04             	mov    0x4(%eax),%eax
c0102a3b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a3e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102a41:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102a44:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102a47:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102a4a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a50:	89 10                	mov    %edx,(%eax)
c0102a52:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a55:	8b 10                	mov    (%eax),%edx
c0102a57:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a60:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a63:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a69:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a6c:	89 10                	mov    %edx,(%eax)
    check_order();
c0102a6e:	e8 09 fe ff ff       	call   c010287c <check_order>
    cprintf("default_init_memmap: nr free page is %d\n",nr_free);
c0102a73:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c0102a78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a7c:	c7 04 24 dc 79 10 c0 	movl   $0xc01079dc,(%esp)
c0102a83:	e8 3f d7 ff ff       	call   c01001c7 <cprintf>
}
c0102a88:	c9                   	leave  
c0102a89:	c3                   	ret    

c0102a8a <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102a8a:	55                   	push   %ebp
c0102a8b:	89 e5                	mov    %esp,%ebp
c0102a8d:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a90:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a94:	75 24                	jne    c0102aba <default_alloc_pages+0x30>
c0102a96:	c7 44 24 0c b1 79 10 	movl   $0xc01079b1,0xc(%esp)
c0102a9d:	c0 
c0102a9e:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0102aa5:	c0 
c0102aa6:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0102aad:	00 
c0102aae:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0102ab5:	e8 a3 e0 ff ff       	call   c0100b5d <__panic>
    if (n > nr_free) {
c0102aba:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c0102abf:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ac2:	73 0a                	jae    c0102ace <default_alloc_pages+0x44>
        return NULL;
c0102ac4:	b8 00 00 00 00       	mov    $0x0,%eax
c0102ac9:	e9 3b 01 00 00       	jmp    c0102c09 <default_alloc_pages+0x17f>
    }
    struct Page *page = NULL;
c0102ace:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102ad5:	c7 45 f0 b8 d9 11 c0 	movl   $0xc011d9b8,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102adc:	eb 1c                	jmp    c0102afa <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ae1:	83 e8 0c             	sub    $0xc,%eax
c0102ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102aea:	8b 40 08             	mov    0x8(%eax),%eax
c0102aed:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102af0:	72 08                	jb     c0102afa <default_alloc_pages+0x70>
            page = p;
c0102af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102af8:	eb 18                	jmp    c0102b12 <default_alloc_pages+0x88>
c0102afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102afd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b03:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0102b06:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102b09:	81 7d f0 b8 d9 11 c0 	cmpl   $0xc011d9b8,-0x10(%ebp)
c0102b10:	75 cc                	jne    c0102ade <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102b12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102b16:	0f 84 e5 00 00 00    	je     c0102c01 <default_alloc_pages+0x177>
        list_del(&(page->page_link));
c0102b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b1f:	83 c0 0c             	add    $0xc,%eax
c0102b22:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102b25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102b28:	8b 40 04             	mov    0x4(%eax),%eax
c0102b2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102b2e:	8b 12                	mov    (%edx),%edx
c0102b30:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0102b33:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102b36:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b39:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b3c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102b3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b42:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102b45:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
c0102b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b4a:	8b 40 08             	mov    0x8(%eax),%eax
c0102b4d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b50:	0f 86 85 00 00 00    	jbe    c0102bdb <default_alloc_pages+0x151>
            struct Page *p = page + n;
c0102b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b59:	c1 e0 05             	shl    $0x5,%eax
c0102b5c:	89 c2                	mov    %eax,%edx
c0102b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b61:	01 d0                	add    %edx,%eax
c0102b63:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b69:	8b 40 08             	mov    0x8(%eax),%eax
c0102b6c:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b6f:	89 c2                	mov    %eax,%edx
c0102b71:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b74:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102b77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b7a:	83 c0 04             	add    $0x4,%eax
c0102b7d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102b84:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102b87:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b8d:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(page->page_link.prev, &(p->page_link));
c0102b90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b93:	8d 50 0c             	lea    0xc(%eax),%edx
c0102b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b99:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b9c:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102b9f:	89 55 c8             	mov    %edx,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102ba2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ba5:	8b 40 04             	mov    0x4(%eax),%eax
c0102ba8:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102bab:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0102bae:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102bb1:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102bb4:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102bb7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102bba:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102bbd:	89 10                	mov    %edx,(%eax)
c0102bbf:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102bc2:	8b 10                	mov    (%eax),%edx
c0102bc4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102bc7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102bca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102bcd:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102bd0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102bd3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102bd6:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102bd9:	89 10                	mov    %edx,(%eax)
        }
        nr_free -= n;
c0102bdb:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c0102be0:	2b 45 08             	sub    0x8(%ebp),%eax
c0102be3:	a3 c0 d9 11 c0       	mov    %eax,0xc011d9c0
        ClearPageProperty(page);
c0102be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102beb:	83 c0 04             	add    $0x4,%eax
c0102bee:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102bf5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102bf8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102bfb:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102bfe:	0f b3 10             	btr    %edx,(%eax)
    }
    check_order();
c0102c01:	e8 76 fc ff ff       	call   c010287c <check_order>
    return page;
c0102c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c09:	c9                   	leave  
c0102c0a:	c3                   	ret    

c0102c0b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102c0b:	55                   	push   %ebp
c0102c0c:	89 e5                	mov    %esp,%ebp
c0102c0e:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    assert(n > 0);
c0102c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102c18:	75 24                	jne    c0102c3e <default_free_pages+0x33>
c0102c1a:	c7 44 24 0c b1 79 10 	movl   $0xc01079b1,0xc(%esp)
c0102c21:	c0 
c0102c22:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0102c29:	c0 
c0102c2a:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
c0102c31:	00 
c0102c32:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0102c39:	e8 1f df ff ff       	call   c0100b5d <__panic>
    struct Page *p = base;
c0102c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102c44:	e9 9d 00 00 00       	jmp    c0102ce6 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c4c:	83 c0 04             	add    $0x4,%eax
c0102c4f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0102c56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c5c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0102c5f:	0f a3 10             	bt     %edx,(%eax)
c0102c62:	19 c0                	sbb    %eax,%eax
c0102c64:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0102c67:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0102c6b:	0f 95 c0             	setne  %al
c0102c6e:	0f b6 c0             	movzbl %al,%eax
c0102c71:	85 c0                	test   %eax,%eax
c0102c73:	75 2c                	jne    c0102ca1 <default_free_pages+0x96>
c0102c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c78:	83 c0 04             	add    $0x4,%eax
c0102c7b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0102c82:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102c88:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c8b:	0f a3 10             	bt     %edx,(%eax)
c0102c8e:	19 c0                	sbb    %eax,%eax
c0102c90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0102c93:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0102c97:	0f 95 c0             	setne  %al
c0102c9a:	0f b6 c0             	movzbl %al,%eax
c0102c9d:	85 c0                	test   %eax,%eax
c0102c9f:	74 24                	je     c0102cc5 <default_free_pages+0xba>
c0102ca1:	c7 44 24 0c 08 7a 10 	movl   $0xc0107a08,0xc(%esp)
c0102ca8:	c0 
c0102ca9:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0102cb0:	c0 
c0102cb1:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0102cb8:	00 
c0102cb9:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0102cc0:	e8 98 de ff ff       	call   c0100b5d <__panic>
        p->flags = 0;
c0102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cc8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102ccf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102cd6:	00 
c0102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cda:	89 04 24             	mov    %eax,(%esp)
c0102cdd:	e8 05 fb ff ff       	call   c01027e7 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102ce2:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0102ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ce9:	c1 e0 05             	shl    $0x5,%eax
c0102cec:	89 c2                	mov    %eax,%edx
c0102cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf1:	01 d0                	add    %edx,%eax
c0102cf3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102cf6:	0f 85 4d ff ff ff    	jne    c0102c49 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102cfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d02:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d08:	83 c0 04             	add    $0x4,%eax
c0102d0b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102d12:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d15:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d18:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102d1b:	0f ab 10             	bts    %edx,(%eax)
c0102d1e:	c7 45 c8 b8 d9 11 c0 	movl   $0xc011d9b8,-0x38(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102d25:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102d28:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102d2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102d2e:	e9 fa 00 00 00       	jmp    c0102e2d <default_free_pages+0x222>
        p = le2page(le, page_link);
c0102d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d36:	83 e8 0c             	sub    $0xc,%eax
c0102d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d3f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102d42:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d45:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102d48:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102d4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d4e:	8b 40 08             	mov    0x8(%eax),%eax
c0102d51:	c1 e0 05             	shl    $0x5,%eax
c0102d54:	89 c2                	mov    %eax,%edx
c0102d56:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d59:	01 d0                	add    %edx,%eax
c0102d5b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102d5e:	75 5a                	jne    c0102dba <default_free_pages+0x1af>
            base->property += p->property;
c0102d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d63:	8b 50 08             	mov    0x8(%eax),%edx
c0102d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d69:	8b 40 08             	mov    0x8(%eax),%eax
c0102d6c:	01 c2                	add    %eax,%edx
c0102d6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d71:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d77:	83 c0 04             	add    $0x4,%eax
c0102d7a:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102d81:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d84:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d87:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102d8a:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d90:	83 c0 0c             	add    $0xc,%eax
c0102d93:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d96:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d99:	8b 40 04             	mov    0x4(%eax),%eax
c0102d9c:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d9f:	8b 12                	mov    (%edx),%edx
c0102da1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0102da4:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102da7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102daa:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102dad:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102db0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102db3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102db6:	89 10                	mov    %edx,(%eax)
c0102db8:	eb 73                	jmp    c0102e2d <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c0102dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbd:	8b 40 08             	mov    0x8(%eax),%eax
c0102dc0:	c1 e0 05             	shl    $0x5,%eax
c0102dc3:	89 c2                	mov    %eax,%edx
c0102dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dc8:	01 d0                	add    %edx,%eax
c0102dca:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102dcd:	75 5e                	jne    c0102e2d <default_free_pages+0x222>
            p->property += base->property;
c0102dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dd2:	8b 50 08             	mov    0x8(%eax),%edx
c0102dd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dd8:	8b 40 08             	mov    0x8(%eax),%eax
c0102ddb:	01 c2                	add    %eax,%edx
c0102ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102de0:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102de3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102de6:	83 c0 04             	add    $0x4,%eax
c0102de9:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0102df0:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102df3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102df6:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102df9:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dff:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e05:	83 c0 0c             	add    $0xc,%eax
c0102e08:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102e0b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e0e:	8b 40 04             	mov    0x4(%eax),%eax
c0102e11:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e14:	8b 12                	mov    (%edx),%edx
c0102e16:	89 55 a0             	mov    %edx,-0x60(%ebp)
c0102e19:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102e1c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e1f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102e22:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102e25:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102e28:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102e2b:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102e2d:	81 7d f0 b8 d9 11 c0 	cmpl   $0xc011d9b8,-0x10(%ebp)
c0102e34:	0f 85 f9 fe ff ff    	jne    c0102d33 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    le = &free_list;
c0102e3a:	c7 45 f0 b8 d9 11 c0 	movl   $0xc011d9b8,-0x10(%ebp)
c0102e41:	c7 45 98 b8 d9 11 c0 	movl   $0xc011d9b8,-0x68(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0102e48:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e4b:	8b 40 04             	mov    0x4(%eax),%eax
c0102e4e:	39 45 98             	cmp    %eax,-0x68(%ebp)
c0102e51:	0f 94 c0             	sete   %al
c0102e54:	0f b6 c0             	movzbl %al,%eax
    if (list_empty(&free_list))
c0102e57:	85 c0                	test   %eax,%eax
c0102e59:	74 66                	je     c0102ec1 <default_free_pages+0x2b6>
        list_add(&free_list, &(base->page_link));
c0102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e5e:	83 c0 0c             	add    $0xc,%eax
c0102e61:	c7 45 94 b8 d9 11 c0 	movl   $0xc011d9b8,-0x6c(%ebp)
c0102e68:	89 45 90             	mov    %eax,-0x70(%ebp)
c0102e6b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e6e:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0102e71:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102e74:	89 45 88             	mov    %eax,-0x78(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102e77:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e7a:	8b 40 04             	mov    0x4(%eax),%eax
c0102e7d:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102e80:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0102e83:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102e86:	89 55 80             	mov    %edx,-0x80(%ebp)
c0102e89:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102e8f:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102e95:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e98:	89 10                	mov    %edx,(%eax)
c0102e9a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102ea0:	8b 10                	mov    (%eax),%edx
c0102ea2:	8b 45 80             	mov    -0x80(%ebp),%eax
c0102ea5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102ea8:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102eab:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102eb1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102eb4:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102eb7:	8b 55 80             	mov    -0x80(%ebp),%edx
c0102eba:	89 10                	mov    %edx,(%eax)
c0102ebc:	e9 1e 02 00 00       	jmp    c01030df <default_free_pages+0x4d4>
c0102ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ec4:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102eca:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102ed0:	8b 40 04             	mov    0x4(%eax),%eax
    else if (base < le2page(list_next(le), page_link))
c0102ed3:	83 e8 0c             	sub    $0xc,%eax
c0102ed6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ed9:	76 7e                	jbe    c0102f59 <default_free_pages+0x34e>
        list_add_after(&free_list, &(base->page_link));
c0102edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ede:	83 c0 0c             	add    $0xc,%eax
c0102ee1:	c7 85 74 ff ff ff b8 	movl   $0xc011d9b8,-0x8c(%ebp)
c0102ee8:	d9 11 c0 
c0102eeb:	89 85 70 ff ff ff    	mov    %eax,-0x90(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102ef1:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
c0102ef7:	8b 40 04             	mov    0x4(%eax),%eax
c0102efa:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
c0102f00:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
c0102f06:	8b 95 74 ff ff ff    	mov    -0x8c(%ebp),%edx
c0102f0c:	89 95 68 ff ff ff    	mov    %edx,-0x98(%ebp)
c0102f12:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102f18:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0102f1e:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
c0102f24:	89 10                	mov    %edx,(%eax)
c0102f26:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0102f2c:	8b 10                	mov    (%eax),%edx
c0102f2e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
c0102f34:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102f37:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0102f3d:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
c0102f43:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102f46:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0102f4c:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
c0102f52:	89 10                	mov    %edx,(%eax)
c0102f54:	e9 86 01 00 00       	jmp    c01030df <default_free_pages+0x4d4>
c0102f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f5c:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0102f62:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
c0102f68:	8b 00                	mov    (%eax),%eax
    else if (base > le2page(list_prev(le), page_link))
c0102f6a:	83 e8 0c             	sub    $0xc,%eax
c0102f6d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102f70:	73 7d                	jae    c0102fef <default_free_pages+0x3e4>
        list_add_before(&free_list, &(base->page_link));
c0102f72:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f75:	83 c0 0c             	add    $0xc,%eax
c0102f78:	c7 85 5c ff ff ff b8 	movl   $0xc011d9b8,-0xa4(%ebp)
c0102f7f:	d9 11 c0 
c0102f82:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102f88:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
c0102f8e:	8b 00                	mov    (%eax),%eax
c0102f90:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
c0102f96:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
c0102f9c:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
c0102fa2:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
c0102fa8:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102fae:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
c0102fb4:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
c0102fba:	89 10                	mov    %edx,(%eax)
c0102fbc:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
c0102fc2:	8b 10                	mov    (%eax),%edx
c0102fc4:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
c0102fca:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102fcd:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
c0102fd3:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
c0102fd9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102fdc:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
c0102fe2:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
c0102fe8:	89 10                	mov    %edx,(%eax)
c0102fea:	e9 f0 00 00 00       	jmp    c01030df <default_free_pages+0x4d4>
    else {
        bool no_add = 0;
c0102fef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        while ((le = list_next(le)) != &free_list) {
c0102ff6:	e9 8f 00 00 00       	jmp    c010308a <default_free_pages+0x47f>
            if (le2page(le, page_link) > base) {
c0102ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ffe:	83 e8 0c             	sub    $0xc,%eax
c0103001:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103004:	0f 86 80 00 00 00    	jbe    c010308a <default_free_pages+0x47f>
                list_add_before(le, &(base->page_link));
c010300a:	8b 45 08             	mov    0x8(%ebp),%eax
c010300d:	8d 50 0c             	lea    0xc(%eax),%edx
c0103010:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103013:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
c0103019:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010301f:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
c0103025:	8b 00                	mov    (%eax),%eax
c0103027:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
c010302d:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
c0103033:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
c0103039:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
c010303f:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103045:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
c010304b:	8b 95 40 ff ff ff    	mov    -0xc0(%ebp),%edx
c0103051:	89 10                	mov    %edx,(%eax)
c0103053:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
c0103059:	8b 10                	mov    (%eax),%edx
c010305b:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
c0103061:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103064:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
c010306a:	8b 95 38 ff ff ff    	mov    -0xc8(%ebp),%edx
c0103070:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103073:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
c0103079:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
c010307f:	89 10                	mov    %edx,(%eax)
                no_add = 1;
c0103081:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
                break;
c0103088:	eb 22                	jmp    c01030ac <default_free_pages+0x4a1>
c010308a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010308d:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103093:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
c0103099:	8b 40 04             	mov    0x4(%eax),%eax
        list_add_after(&free_list, &(base->page_link));
    else if (base > le2page(list_prev(le), page_link))
        list_add_before(&free_list, &(base->page_link));
    else {
        bool no_add = 0;
        while ((le = list_next(le)) != &free_list) {
c010309c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010309f:	81 7d f0 b8 d9 11 c0 	cmpl   $0xc011d9b8,-0x10(%ebp)
c01030a6:	0f 85 4f ff ff ff    	jne    c0102ffb <default_free_pages+0x3f0>
                list_add_before(le, &(base->page_link));
                no_add = 1;
                break;
            }
        }
        if (!no_add)
c01030ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01030b0:	75 2d                	jne    c01030df <default_free_pages+0x4d4>
            panic("Failed to add %x %d\n", base, base->property);
c01030b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01030b5:	8b 40 08             	mov    0x8(%eax),%eax
c01030b8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01030bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01030bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01030c3:	c7 44 24 08 2d 7a 10 	movl   $0xc0107a2d,0x8(%esp)
c01030ca:	c0 
c01030cb:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c01030d2:	00 
c01030d3:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01030da:	e8 7e da ff ff       	call   c0100b5d <__panic>
    }
    nr_free += n;
c01030df:	8b 15 c0 d9 11 c0    	mov    0xc011d9c0,%edx
c01030e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030e8:	01 d0                	add    %edx,%eax
c01030ea:	a3 c0 d9 11 c0       	mov    %eax,0xc011d9c0
    check_order();
c01030ef:	e8 88 f7 ff ff       	call   c010287c <check_order>
}
c01030f4:	c9                   	leave  
c01030f5:	c3                   	ret    

c01030f6 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01030f6:	55                   	push   %ebp
c01030f7:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01030f9:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
}
c01030fe:	5d                   	pop    %ebp
c01030ff:	c3                   	ret    

c0103100 <basic_check>:

static void
basic_check(void) {
c0103100:	55                   	push   %ebp
c0103101:	89 e5                	mov    %esp,%ebp
c0103103:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
	cprintf("default_pmm basic_check\n");
c0103106:	c7 04 24 42 7a 10 c0 	movl   $0xc0107a42,(%esp)
c010310d:	e8 b5 d0 ff ff       	call   c01001c7 <cprintf>
    p0 = p1 = p2 = NULL;
c0103112:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103119:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010311c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010311f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103122:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010312c:	e8 71 0f 00 00       	call   c01040a2 <alloc_pages>
c0103131:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103134:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103138:	75 24                	jne    c010315e <basic_check+0x5e>
c010313a:	c7 44 24 0c 5b 7a 10 	movl   $0xc0107a5b,0xc(%esp)
c0103141:	c0 
c0103142:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103149:	c0 
c010314a:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103151:	00 
c0103152:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103159:	e8 ff d9 ff ff       	call   c0100b5d <__panic>
    assert((p1 = alloc_page()) != NULL);
c010315e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103165:	e8 38 0f 00 00       	call   c01040a2 <alloc_pages>
c010316a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010316d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103171:	75 24                	jne    c0103197 <basic_check+0x97>
c0103173:	c7 44 24 0c 77 7a 10 	movl   $0xc0107a77,0xc(%esp)
c010317a:	c0 
c010317b:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103182:	c0 
c0103183:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010318a:	00 
c010318b:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103192:	e8 c6 d9 ff ff       	call   c0100b5d <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010319e:	e8 ff 0e 00 00       	call   c01040a2 <alloc_pages>
c01031a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01031aa:	75 24                	jne    c01031d0 <basic_check+0xd0>
c01031ac:	c7 44 24 0c 93 7a 10 	movl   $0xc0107a93,0xc(%esp)
c01031b3:	c0 
c01031b4:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01031bb:	c0 
c01031bc:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01031c3:	00 
c01031c4:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01031cb:	e8 8d d9 ff ff       	call   c0100b5d <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01031d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01031d6:	74 10                	je     c01031e8 <basic_check+0xe8>
c01031d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031db:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01031de:	74 08                	je     c01031e8 <basic_check+0xe8>
c01031e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031e3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01031e6:	75 24                	jne    c010320c <basic_check+0x10c>
c01031e8:	c7 44 24 0c b0 7a 10 	movl   $0xc0107ab0,0xc(%esp)
c01031ef:	c0 
c01031f0:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01031f7:	c0 
c01031f8:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01031ff:	00 
c0103200:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103207:	e8 51 d9 ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010320c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010320f:	89 04 24             	mov    %eax,(%esp)
c0103212:	e8 c6 f5 ff ff       	call   c01027dd <page_ref>
c0103217:	85 c0                	test   %eax,%eax
c0103219:	75 1e                	jne    c0103239 <basic_check+0x139>
c010321b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010321e:	89 04 24             	mov    %eax,(%esp)
c0103221:	e8 b7 f5 ff ff       	call   c01027dd <page_ref>
c0103226:	85 c0                	test   %eax,%eax
c0103228:	75 0f                	jne    c0103239 <basic_check+0x139>
c010322a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010322d:	89 04 24             	mov    %eax,(%esp)
c0103230:	e8 a8 f5 ff ff       	call   c01027dd <page_ref>
c0103235:	85 c0                	test   %eax,%eax
c0103237:	74 24                	je     c010325d <basic_check+0x15d>
c0103239:	c7 44 24 0c d4 7a 10 	movl   $0xc0107ad4,0xc(%esp)
c0103240:	c0 
c0103241:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103248:	c0 
c0103249:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103250:	00 
c0103251:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103258:	e8 00 d9 ff ff       	call   c0100b5d <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010325d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103260:	89 04 24             	mov    %eax,(%esp)
c0103263:	e8 5f f5 ff ff       	call   c01027c7 <page2pa>
c0103268:	8b 15 00 d9 11 c0    	mov    0xc011d900,%edx
c010326e:	c1 e2 0c             	shl    $0xc,%edx
c0103271:	39 d0                	cmp    %edx,%eax
c0103273:	72 24                	jb     c0103299 <basic_check+0x199>
c0103275:	c7 44 24 0c 10 7b 10 	movl   $0xc0107b10,0xc(%esp)
c010327c:	c0 
c010327d:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103284:	c0 
c0103285:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010328c:	00 
c010328d:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103294:	e8 c4 d8 ff ff       	call   c0100b5d <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103299:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010329c:	89 04 24             	mov    %eax,(%esp)
c010329f:	e8 23 f5 ff ff       	call   c01027c7 <page2pa>
c01032a4:	8b 15 00 d9 11 c0    	mov    0xc011d900,%edx
c01032aa:	c1 e2 0c             	shl    $0xc,%edx
c01032ad:	39 d0                	cmp    %edx,%eax
c01032af:	72 24                	jb     c01032d5 <basic_check+0x1d5>
c01032b1:	c7 44 24 0c 2d 7b 10 	movl   $0xc0107b2d,0xc(%esp)
c01032b8:	c0 
c01032b9:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01032c0:	c0 
c01032c1:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c01032c8:	00 
c01032c9:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01032d0:	e8 88 d8 ff ff       	call   c0100b5d <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032d8:	89 04 24             	mov    %eax,(%esp)
c01032db:	e8 e7 f4 ff ff       	call   c01027c7 <page2pa>
c01032e0:	8b 15 00 d9 11 c0    	mov    0xc011d900,%edx
c01032e6:	c1 e2 0c             	shl    $0xc,%edx
c01032e9:	39 d0                	cmp    %edx,%eax
c01032eb:	72 24                	jb     c0103311 <basic_check+0x211>
c01032ed:	c7 44 24 0c 4a 7b 10 	movl   $0xc0107b4a,0xc(%esp)
c01032f4:	c0 
c01032f5:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01032fc:	c0 
c01032fd:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103304:	00 
c0103305:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c010330c:	e8 4c d8 ff ff       	call   c0100b5d <__panic>

    list_entry_t free_list_store = free_list;
c0103311:	a1 b8 d9 11 c0       	mov    0xc011d9b8,%eax
c0103316:	8b 15 bc d9 11 c0    	mov    0xc011d9bc,%edx
c010331c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010331f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103322:	c7 45 e0 b8 d9 11 c0 	movl   $0xc011d9b8,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103329:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010332c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010332f:	89 50 04             	mov    %edx,0x4(%eax)
c0103332:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103335:	8b 50 04             	mov    0x4(%eax),%edx
c0103338:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010333b:	89 10                	mov    %edx,(%eax)
c010333d:	c7 45 dc b8 d9 11 c0 	movl   $0xc011d9b8,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103344:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103347:	8b 40 04             	mov    0x4(%eax),%eax
c010334a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010334d:	0f 94 c0             	sete   %al
c0103350:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103353:	85 c0                	test   %eax,%eax
c0103355:	75 24                	jne    c010337b <basic_check+0x27b>
c0103357:	c7 44 24 0c 67 7b 10 	movl   $0xc0107b67,0xc(%esp)
c010335e:	c0 
c010335f:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103366:	c0 
c0103367:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010336e:	00 
c010336f:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103376:	e8 e2 d7 ff ff       	call   c0100b5d <__panic>

    unsigned int nr_free_store = nr_free;
c010337b:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c0103380:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103383:	c7 05 c0 d9 11 c0 00 	movl   $0x0,0xc011d9c0
c010338a:	00 00 00 

    assert(alloc_page() == NULL);
c010338d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103394:	e8 09 0d 00 00       	call   c01040a2 <alloc_pages>
c0103399:	85 c0                	test   %eax,%eax
c010339b:	74 24                	je     c01033c1 <basic_check+0x2c1>
c010339d:	c7 44 24 0c 7e 7b 10 	movl   $0xc0107b7e,0xc(%esp)
c01033a4:	c0 
c01033a5:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01033ac:	c0 
c01033ad:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c01033b4:	00 
c01033b5:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01033bc:	e8 9c d7 ff ff       	call   c0100b5d <__panic>

    free_page(p0);
c01033c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033c8:	00 
c01033c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033cc:	89 04 24             	mov    %eax,(%esp)
c01033cf:	e8 28 0d 00 00       	call   c01040fc <free_pages>
    free_page(p1);
c01033d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033db:	00 
c01033dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033df:	89 04 24             	mov    %eax,(%esp)
c01033e2:	e8 15 0d 00 00       	call   c01040fc <free_pages>
    free_page(p2);
c01033e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033ee:	00 
c01033ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f2:	89 04 24             	mov    %eax,(%esp)
c01033f5:	e8 02 0d 00 00       	call   c01040fc <free_pages>
    assert(nr_free == 3);
c01033fa:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c01033ff:	83 f8 03             	cmp    $0x3,%eax
c0103402:	74 24                	je     c0103428 <basic_check+0x328>
c0103404:	c7 44 24 0c 93 7b 10 	movl   $0xc0107b93,0xc(%esp)
c010340b:	c0 
c010340c:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103413:	c0 
c0103414:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010341b:	00 
c010341c:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103423:	e8 35 d7 ff ff       	call   c0100b5d <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103428:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010342f:	e8 6e 0c 00 00       	call   c01040a2 <alloc_pages>
c0103434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103437:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010343b:	75 24                	jne    c0103461 <basic_check+0x361>
c010343d:	c7 44 24 0c 5b 7a 10 	movl   $0xc0107a5b,0xc(%esp)
c0103444:	c0 
c0103445:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c010344c:	c0 
c010344d:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103454:	00 
c0103455:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c010345c:	e8 fc d6 ff ff       	call   c0100b5d <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103461:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103468:	e8 35 0c 00 00       	call   c01040a2 <alloc_pages>
c010346d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103470:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103474:	75 24                	jne    c010349a <basic_check+0x39a>
c0103476:	c7 44 24 0c 77 7a 10 	movl   $0xc0107a77,0xc(%esp)
c010347d:	c0 
c010347e:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103485:	c0 
c0103486:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010348d:	00 
c010348e:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103495:	e8 c3 d6 ff ff       	call   c0100b5d <__panic>
    assert((p2 = alloc_page()) != NULL);
c010349a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034a1:	e8 fc 0b 00 00       	call   c01040a2 <alloc_pages>
c01034a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01034a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034ad:	75 24                	jne    c01034d3 <basic_check+0x3d3>
c01034af:	c7 44 24 0c 93 7a 10 	movl   $0xc0107a93,0xc(%esp)
c01034b6:	c0 
c01034b7:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01034be:	c0 
c01034bf:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01034c6:	00 
c01034c7:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01034ce:	e8 8a d6 ff ff       	call   c0100b5d <__panic>

    assert(alloc_page() == NULL);
c01034d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034da:	e8 c3 0b 00 00       	call   c01040a2 <alloc_pages>
c01034df:	85 c0                	test   %eax,%eax
c01034e1:	74 24                	je     c0103507 <basic_check+0x407>
c01034e3:	c7 44 24 0c 7e 7b 10 	movl   $0xc0107b7e,0xc(%esp)
c01034ea:	c0 
c01034eb:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01034f2:	c0 
c01034f3:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01034fa:	00 
c01034fb:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103502:	e8 56 d6 ff ff       	call   c0100b5d <__panic>

    free_page(p0);
c0103507:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010350e:	00 
c010350f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103512:	89 04 24             	mov    %eax,(%esp)
c0103515:	e8 e2 0b 00 00       	call   c01040fc <free_pages>
c010351a:	c7 45 d8 b8 d9 11 c0 	movl   $0xc011d9b8,-0x28(%ebp)
c0103521:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103524:	8b 40 04             	mov    0x4(%eax),%eax
c0103527:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010352a:	0f 94 c0             	sete   %al
c010352d:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103530:	85 c0                	test   %eax,%eax
c0103532:	74 24                	je     c0103558 <basic_check+0x458>
c0103534:	c7 44 24 0c a0 7b 10 	movl   $0xc0107ba0,0xc(%esp)
c010353b:	c0 
c010353c:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c0103543:	c0 
c0103544:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c010354b:	00 
c010354c:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103553:	e8 05 d6 ff ff       	call   c0100b5d <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103558:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010355f:	e8 3e 0b 00 00       	call   c01040a2 <alloc_pages>
c0103564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010356a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010356d:	74 24                	je     c0103593 <basic_check+0x493>
c010356f:	c7 44 24 0c b8 7b 10 	movl   $0xc0107bb8,0xc(%esp)
c0103576:	c0 
c0103577:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c010357e:	c0 
c010357f:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0103586:	00 
c0103587:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c010358e:	e8 ca d5 ff ff       	call   c0100b5d <__panic>
    assert(alloc_page() == NULL);
c0103593:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010359a:	e8 03 0b 00 00       	call   c01040a2 <alloc_pages>
c010359f:	85 c0                	test   %eax,%eax
c01035a1:	74 24                	je     c01035c7 <basic_check+0x4c7>
c01035a3:	c7 44 24 0c 7e 7b 10 	movl   $0xc0107b7e,0xc(%esp)
c01035aa:	c0 
c01035ab:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01035b2:	c0 
c01035b3:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01035ba:	00 
c01035bb:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01035c2:	e8 96 d5 ff ff       	call   c0100b5d <__panic>

    assert(nr_free == 0);
c01035c7:	a1 c0 d9 11 c0       	mov    0xc011d9c0,%eax
c01035cc:	85 c0                	test   %eax,%eax
c01035ce:	74 24                	je     c01035f4 <basic_check+0x4f4>
c01035d0:	c7 44 24 0c d1 7b 10 	movl   $0xc0107bd1,0xc(%esp)
c01035d7:	c0 
c01035d8:	c7 44 24 08 b7 79 10 	movl   $0xc01079b7,0x8(%esp)
c01035df:	c0 
c01035e0:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c01035e7:	00 
c01035e8:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c01035ef:	e8 69 d5 ff ff       	call   c0100b5d <__panic>
    free_list = free_list_store;
c01035f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035fa:	a3 b8 d9 11 c0       	mov    %eax,0xc011d9b8
c01035ff:	89 15 bc d9 11 c0    	mov    %edx,0xc011d9bc
    nr_free = nr_free_store;
c0103605:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103608:	a3 c0 d9 11 c0       	mov    %eax,0xc011d9c0

    free_page(p);
c010360d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103614:	00 
c0103615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103618:	89 04 24             	mov    %eax,(%esp)
c010361b:	e8 dc 0a 00 00       	call   c01040fc <free_pages>
    free_page(p1);
c0103620:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103627:	00 
c0103628:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010362b:	89 04 24             	mov    %eax,(%esp)
c010362e:	e8 c9 0a 00 00       	call   c01040fc <free_pages>
    free_page(p2);
c0103633:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010363a:	00 
c010363b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363e:	89 04 24             	mov    %eax,(%esp)
c0103641:	e8 b6 0a 00 00       	call   c01040fc <free_pages>
}
c0103646:	c9                   	leave  
c0103647:	c3                   	ret    

c0103648 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103648:	55                   	push   %ebp
c0103649:	89 e5                	mov    %esp,%ebp

}
c010364b:	5d                   	pop    %ebp
c010364c:	c3                   	ret    

c010364d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010364d:	55                   	push   %ebp
c010364e:	89 e5                	mov    %esp,%ebp
c0103650:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103653:	9c                   	pushf  
c0103654:	58                   	pop    %eax
c0103655:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103658:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010365b:	25 00 02 00 00       	and    $0x200,%eax
c0103660:	85 c0                	test   %eax,%eax
c0103662:	74 0c                	je     c0103670 <__intr_save+0x23>
        intr_disable();
c0103664:	e8 d7 de ff ff       	call   c0101540 <intr_disable>
        return 1;
c0103669:	b8 01 00 00 00       	mov    $0x1,%eax
c010366e:	eb 05                	jmp    c0103675 <__intr_save+0x28>
    }
    return 0;
c0103670:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103675:	c9                   	leave  
c0103676:	c3                   	ret    

c0103677 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103677:	55                   	push   %ebp
c0103678:	89 e5                	mov    %esp,%ebp
c010367a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010367d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103681:	74 05                	je     c0103688 <__intr_restore+0x11>
        intr_enable();
c0103683:	e8 b2 de ff ff       	call   c010153a <intr_enable>
    }
}
c0103688:	c9                   	leave  
c0103689:	c3                   	ret    

c010368a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010368a:	55                   	push   %ebp
c010368b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010368d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103690:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0103695:	29 c2                	sub    %eax,%edx
c0103697:	89 d0                	mov    %edx,%eax
c0103699:	c1 f8 05             	sar    $0x5,%eax
}
c010369c:	5d                   	pop    %ebp
c010369d:	c3                   	ret    

c010369e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010369e:	55                   	push   %ebp
c010369f:	89 e5                	mov    %esp,%ebp
c01036a1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01036a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a7:	89 04 24             	mov    %eax,(%esp)
c01036aa:	e8 db ff ff ff       	call   c010368a <page2ppn>
c01036af:	c1 e0 0c             	shl    $0xc,%eax
}
c01036b2:	c9                   	leave  
c01036b3:	c3                   	ret    

c01036b4 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01036b4:	55                   	push   %ebp
c01036b5:	89 e5                	mov    %esp,%ebp
c01036b7:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01036ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01036bd:	c1 e8 0c             	shr    $0xc,%eax
c01036c0:	89 c2                	mov    %eax,%edx
c01036c2:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c01036c7:	39 c2                	cmp    %eax,%edx
c01036c9:	72 1c                	jb     c01036e7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01036cb:	c7 44 24 08 10 7c 10 	movl   $0xc0107c10,0x8(%esp)
c01036d2:	c0 
c01036d3:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01036da:	00 
c01036db:	c7 04 24 2f 7c 10 c0 	movl   $0xc0107c2f,(%esp)
c01036e2:	e8 76 d4 ff ff       	call   c0100b5d <__panic>
    }
    return &pages[PPN(pa)];
c01036e7:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c01036ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01036ef:	c1 ea 0c             	shr    $0xc,%edx
c01036f2:	c1 e2 05             	shl    $0x5,%edx
c01036f5:	01 d0                	add    %edx,%eax
}
c01036f7:	c9                   	leave  
c01036f8:	c3                   	ret    

c01036f9 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01036f9:	55                   	push   %ebp
c01036fa:	89 e5                	mov    %esp,%ebp
c01036fc:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01036ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103702:	89 04 24             	mov    %eax,(%esp)
c0103705:	e8 94 ff ff ff       	call   c010369e <page2pa>
c010370a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010370d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103710:	c1 e8 0c             	shr    $0xc,%eax
c0103713:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103716:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c010371b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010371e:	72 23                	jb     c0103743 <page2kva+0x4a>
c0103720:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103723:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103727:	c7 44 24 08 40 7c 10 	movl   $0xc0107c40,0x8(%esp)
c010372e:	c0 
c010372f:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0103736:	00 
c0103737:	c7 04 24 2f 7c 10 c0 	movl   $0xc0107c2f,(%esp)
c010373e:	e8 1a d4 ff ff       	call   c0100b5d <__panic>
c0103743:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103746:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010374b:	c9                   	leave  
c010374c:	c3                   	ret    

c010374d <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c010374d:	55                   	push   %ebp
c010374e:	89 e5                	mov    %esp,%ebp
c0103750:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0103753:	8b 45 08             	mov    0x8(%ebp),%eax
c0103756:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103759:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103760:	77 23                	ja     c0103785 <kva2page+0x38>
c0103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103765:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103769:	c7 44 24 08 64 7c 10 	movl   $0xc0107c64,0x8(%esp)
c0103770:	c0 
c0103771:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0103778:	00 
c0103779:	c7 04 24 2f 7c 10 c0 	movl   $0xc0107c2f,(%esp)
c0103780:	e8 d8 d3 ff ff       	call   c0100b5d <__panic>
c0103785:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103788:	05 00 00 00 40       	add    $0x40000000,%eax
c010378d:	89 04 24             	mov    %eax,(%esp)
c0103790:	e8 1f ff ff ff       	call   c01036b4 <pa2page>
}
c0103795:	c9                   	leave  
c0103796:	c3                   	ret    

c0103797 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0103797:	55                   	push   %ebp
c0103798:	89 e5                	mov    %esp,%ebp
c010379a:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c010379d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037a0:	ba 01 00 00 00       	mov    $0x1,%edx
c01037a5:	89 c1                	mov    %eax,%ecx
c01037a7:	d3 e2                	shl    %cl,%edx
c01037a9:	89 d0                	mov    %edx,%eax
c01037ab:	89 04 24             	mov    %eax,(%esp)
c01037ae:	e8 ef 08 00 00       	call   c01040a2 <alloc_pages>
c01037b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01037b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037ba:	75 07                	jne    c01037c3 <__slob_get_free_pages+0x2c>
    return NULL;
c01037bc:	b8 00 00 00 00       	mov    $0x0,%eax
c01037c1:	eb 0b                	jmp    c01037ce <__slob_get_free_pages+0x37>
  return page2kva(page);
c01037c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037c6:	89 04 24             	mov    %eax,(%esp)
c01037c9:	e8 2b ff ff ff       	call   c01036f9 <page2kva>
}
c01037ce:	c9                   	leave  
c01037cf:	c3                   	ret    

c01037d0 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c01037d0:	55                   	push   %ebp
c01037d1:	89 e5                	mov    %esp,%ebp
c01037d3:	53                   	push   %ebx
c01037d4:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01037d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037da:	ba 01 00 00 00       	mov    $0x1,%edx
c01037df:	89 c1                	mov    %eax,%ecx
c01037e1:	d3 e2                	shl    %cl,%edx
c01037e3:	89 d0                	mov    %edx,%eax
c01037e5:	89 c3                	mov    %eax,%ebx
c01037e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01037ea:	89 04 24             	mov    %eax,(%esp)
c01037ed:	e8 5b ff ff ff       	call   c010374d <kva2page>
c01037f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01037f6:	89 04 24             	mov    %eax,(%esp)
c01037f9:	e8 fe 08 00 00       	call   c01040fc <free_pages>
}
c01037fe:	83 c4 14             	add    $0x14,%esp
c0103801:	5b                   	pop    %ebx
c0103802:	5d                   	pop    %ebp
c0103803:	c3                   	ret    

c0103804 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0103804:	55                   	push   %ebp
c0103805:	89 e5                	mov    %esp,%ebp
c0103807:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010380a:	8b 45 08             	mov    0x8(%ebp),%eax
c010380d:	83 c0 08             	add    $0x8,%eax
c0103810:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0103815:	76 24                	jbe    c010383b <slob_alloc+0x37>
c0103817:	c7 44 24 0c 88 7c 10 	movl   $0xc0107c88,0xc(%esp)
c010381e:	c0 
c010381f:	c7 44 24 08 a7 7c 10 	movl   $0xc0107ca7,0x8(%esp)
c0103826:	c0 
c0103827:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010382e:	00 
c010382f:	c7 04 24 bc 7c 10 c0 	movl   $0xc0107cbc,(%esp)
c0103836:	e8 22 d3 ff ff       	call   c0100b5d <__panic>

	slob_t *prev, *cur, *aligned = 0;
c010383b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0103842:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0103849:	8b 45 08             	mov    0x8(%ebp),%eax
c010384c:	83 c0 07             	add    $0x7,%eax
c010384f:	c1 e8 03             	shr    $0x3,%eax
c0103852:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0103855:	e8 f3 fd ff ff       	call   c010364d <__intr_save>
c010385a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c010385d:	a1 08 ca 11 c0       	mov    0xc011ca08,%eax
c0103862:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0103865:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103868:	8b 40 04             	mov    0x4(%eax),%eax
c010386b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010386e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103872:	74 25                	je     c0103899 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0103874:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103877:	8b 45 10             	mov    0x10(%ebp),%eax
c010387a:	01 d0                	add    %edx,%eax
c010387c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010387f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103882:	f7 d8                	neg    %eax
c0103884:	21 d0                	and    %edx,%eax
c0103886:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0103889:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010388c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010388f:	29 c2                	sub    %eax,%edx
c0103891:	89 d0                	mov    %edx,%eax
c0103893:	c1 f8 03             	sar    $0x3,%eax
c0103896:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0103899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010389c:	8b 00                	mov    (%eax),%eax
c010389e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01038a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01038a4:	01 ca                	add    %ecx,%edx
c01038a6:	39 d0                	cmp    %edx,%eax
c01038a8:	0f 8c aa 00 00 00    	jl     c0103958 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01038ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01038b2:	74 38                	je     c01038ec <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01038b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038b7:	8b 00                	mov    (%eax),%eax
c01038b9:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01038bc:	89 c2                	mov    %eax,%edx
c01038be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038c1:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01038c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038c6:	8b 50 04             	mov    0x4(%eax),%edx
c01038c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038cc:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01038cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01038d5:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01038d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038db:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01038de:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01038e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01038e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01038ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038ef:	8b 00                	mov    (%eax),%eax
c01038f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01038f4:	75 0e                	jne    c0103904 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01038f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038f9:	8b 50 04             	mov    0x4(%eax),%edx
c01038fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ff:	89 50 04             	mov    %edx,0x4(%eax)
c0103902:	eb 3c                	jmp    c0103940 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0103904:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103907:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010390e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103911:	01 c2                	add    %eax,%edx
c0103913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103916:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0103919:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391c:	8b 40 04             	mov    0x4(%eax),%eax
c010391f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103922:	8b 12                	mov    (%edx),%edx
c0103924:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0103927:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0103929:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392c:	8b 40 04             	mov    0x4(%eax),%eax
c010392f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103932:	8b 52 04             	mov    0x4(%edx),%edx
c0103935:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0103938:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010393b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010393e:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0103940:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103943:	a3 08 ca 11 c0       	mov    %eax,0xc011ca08
			spin_unlock_irqrestore(&slob_lock, flags);
c0103948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010394b:	89 04 24             	mov    %eax,(%esp)
c010394e:	e8 24 fd ff ff       	call   c0103677 <__intr_restore>
			return cur;
c0103953:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103956:	eb 7f                	jmp    c01039d7 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0103958:	a1 08 ca 11 c0       	mov    0xc011ca08,%eax
c010395d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103960:	75 61                	jne    c01039c3 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0103962:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103965:	89 04 24             	mov    %eax,(%esp)
c0103968:	e8 0a fd ff ff       	call   c0103677 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c010396d:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0103974:	75 07                	jne    c010397d <slob_alloc+0x179>
				return 0;
c0103976:	b8 00 00 00 00       	mov    $0x0,%eax
c010397b:	eb 5a                	jmp    c01039d7 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010397d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103984:	00 
c0103985:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103988:	89 04 24             	mov    %eax,(%esp)
c010398b:	e8 07 fe ff ff       	call   c0103797 <__slob_get_free_pages>
c0103990:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0103993:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103997:	75 07                	jne    c01039a0 <slob_alloc+0x19c>
				return 0;
c0103999:	b8 00 00 00 00       	mov    $0x0,%eax
c010399e:	eb 37                	jmp    c01039d7 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01039a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01039a7:	00 
c01039a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039ab:	89 04 24             	mov    %eax,(%esp)
c01039ae:	e8 26 00 00 00       	call   c01039d9 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01039b3:	e8 95 fc ff ff       	call   c010364d <__intr_save>
c01039b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01039bb:	a1 08 ca 11 c0       	mov    0xc011ca08,%eax
c01039c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01039c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01039c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039cc:	8b 40 04             	mov    0x4(%eax),%eax
c01039cf:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c01039d2:	e9 97 fe ff ff       	jmp    c010386e <slob_alloc+0x6a>
}
c01039d7:	c9                   	leave  
c01039d8:	c3                   	ret    

c01039d9 <slob_free>:

static void slob_free(void *block, int size)
{
c01039d9:	55                   	push   %ebp
c01039da:	89 e5                	mov    %esp,%ebp
c01039dc:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c01039df:	8b 45 08             	mov    0x8(%ebp),%eax
c01039e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01039e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01039e9:	75 05                	jne    c01039f0 <slob_free+0x17>
		return;
c01039eb:	e9 ff 00 00 00       	jmp    c0103aef <slob_free+0x116>

	if (size)
c01039f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01039f4:	74 10                	je     c0103a06 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c01039f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039f9:	83 c0 07             	add    $0x7,%eax
c01039fc:	c1 e8 03             	shr    $0x3,%eax
c01039ff:	89 c2                	mov    %eax,%edx
c0103a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a04:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0103a06:	e8 42 fc ff ff       	call   c010364d <__intr_save>
c0103a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0103a0e:	a1 08 ca 11 c0       	mov    0xc011ca08,%eax
c0103a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a16:	eb 27                	jmp    c0103a3f <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0103a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a1b:	8b 40 04             	mov    0x4(%eax),%eax
c0103a1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a21:	77 13                	ja     c0103a36 <slob_free+0x5d>
c0103a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a26:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a29:	77 27                	ja     c0103a52 <slob_free+0x79>
c0103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a2e:	8b 40 04             	mov    0x4(%eax),%eax
c0103a31:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103a34:	77 1c                	ja     c0103a52 <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0103a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a39:	8b 40 04             	mov    0x4(%eax),%eax
c0103a3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a42:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a45:	76 d1                	jbe    c0103a18 <slob_free+0x3f>
c0103a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a4a:	8b 40 04             	mov    0x4(%eax),%eax
c0103a4d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103a50:	76 c6                	jbe    c0103a18 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a55:	8b 00                	mov    (%eax),%eax
c0103a57:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0103a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a61:	01 c2                	add    %eax,%edx
c0103a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a66:	8b 40 04             	mov    0x4(%eax),%eax
c0103a69:	39 c2                	cmp    %eax,%edx
c0103a6b:	75 25                	jne    c0103a92 <slob_free+0xb9>
		b->units += cur->next->units;
c0103a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a70:	8b 10                	mov    (%eax),%edx
c0103a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a75:	8b 40 04             	mov    0x4(%eax),%eax
c0103a78:	8b 00                	mov    (%eax),%eax
c0103a7a:	01 c2                	add    %eax,%edx
c0103a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7f:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0103a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a84:	8b 40 04             	mov    0x4(%eax),%eax
c0103a87:	8b 50 04             	mov    0x4(%eax),%edx
c0103a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a8d:	89 50 04             	mov    %edx,0x4(%eax)
c0103a90:	eb 0c                	jmp    c0103a9e <slob_free+0xc5>
	} else
		b->next = cur->next;
c0103a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a95:	8b 50 04             	mov    0x4(%eax),%edx
c0103a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a9b:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0103a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aa1:	8b 00                	mov    (%eax),%eax
c0103aa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aad:	01 d0                	add    %edx,%eax
c0103aaf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103ab2:	75 1f                	jne    c0103ad3 <slob_free+0xfa>
		cur->units += b->units;
c0103ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ab7:	8b 10                	mov    (%eax),%edx
c0103ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103abc:	8b 00                	mov    (%eax),%eax
c0103abe:	01 c2                	add    %eax,%edx
c0103ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ac3:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0103ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ac8:	8b 50 04             	mov    0x4(%eax),%edx
c0103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ace:	89 50 04             	mov    %edx,0x4(%eax)
c0103ad1:	eb 09                	jmp    c0103adc <slob_free+0x103>
	} else
		cur->next = b;
c0103ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103ad9:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103adf:	a3 08 ca 11 c0       	mov    %eax,0xc011ca08

	spin_unlock_irqrestore(&slob_lock, flags);
c0103ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ae7:	89 04 24             	mov    %eax,(%esp)
c0103aea:	e8 88 fb ff ff       	call   c0103677 <__intr_restore>
}
c0103aef:	c9                   	leave  
c0103af0:	c3                   	ret    

c0103af1 <slob_init>:



void
slob_init(void) {
c0103af1:	55                   	push   %ebp
c0103af2:	89 e5                	mov    %esp,%ebp
c0103af4:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0103af7:	c7 04 24 ce 7c 10 c0 	movl   $0xc0107cce,(%esp)
c0103afe:	e8 c4 c6 ff ff       	call   c01001c7 <cprintf>
}
c0103b03:	c9                   	leave  
c0103b04:	c3                   	ret    

c0103b05 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0103b05:	55                   	push   %ebp
c0103b06:	89 e5                	mov    %esp,%ebp
c0103b08:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0103b0b:	e8 e1 ff ff ff       	call   c0103af1 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0103b10:	c7 04 24 e2 7c 10 c0 	movl   $0xc0107ce2,(%esp)
c0103b17:	e8 ab c6 ff ff       	call   c01001c7 <cprintf>
}
c0103b1c:	c9                   	leave  
c0103b1d:	c3                   	ret    

c0103b1e <slob_allocated>:

size_t
slob_allocated(void) {
c0103b1e:	55                   	push   %ebp
c0103b1f:	89 e5                	mov    %esp,%ebp
  return 0;
c0103b21:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103b26:	5d                   	pop    %ebp
c0103b27:	c3                   	ret    

c0103b28 <kallocated>:

size_t
kallocated(void) {
c0103b28:	55                   	push   %ebp
c0103b29:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0103b2b:	e8 ee ff ff ff       	call   c0103b1e <slob_allocated>
}
c0103b30:	5d                   	pop    %ebp
c0103b31:	c3                   	ret    

c0103b32 <find_order>:

static int find_order(int size)
{
c0103b32:	55                   	push   %ebp
c0103b33:	89 e5                	mov    %esp,%ebp
c0103b35:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0103b38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0103b3f:	eb 07                	jmp    c0103b48 <find_order+0x16>
		order++;
c0103b41:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0103b45:	d1 7d 08             	sarl   0x8(%ebp)
c0103b48:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0103b4f:	7f f0                	jg     c0103b41 <find_order+0xf>
		order++;
	return order;
c0103b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103b54:	c9                   	leave  
c0103b55:	c3                   	ret    

c0103b56 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0103b56:	55                   	push   %ebp
c0103b57:	89 e5                	mov    %esp,%ebp
c0103b59:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0103b5c:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0103b63:	77 38                	ja     c0103b9d <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0103b65:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b68:	8d 50 08             	lea    0x8(%eax),%edx
c0103b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b72:	00 
c0103b73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b7a:	89 14 24             	mov    %edx,(%esp)
c0103b7d:	e8 82 fc ff ff       	call   c0103804 <slob_alloc>
c0103b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0103b85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b89:	74 08                	je     c0103b93 <__kmalloc+0x3d>
c0103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b8e:	83 c0 08             	add    $0x8,%eax
c0103b91:	eb 05                	jmp    c0103b98 <__kmalloc+0x42>
c0103b93:	b8 00 00 00 00       	mov    $0x0,%eax
c0103b98:	e9 a6 00 00 00       	jmp    c0103c43 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0103b9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ba4:	00 
c0103ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103bac:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0103bb3:	e8 4c fc ff ff       	call   c0103804 <slob_alloc>
c0103bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0103bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103bbf:	75 07                	jne    c0103bc8 <__kmalloc+0x72>
		return 0;
c0103bc1:	b8 00 00 00 00       	mov    $0x0,%eax
c0103bc6:	eb 7b                	jmp    c0103c43 <__kmalloc+0xed>

	bb->order = find_order(size);
c0103bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bcb:	89 04 24             	mov    %eax,(%esp)
c0103bce:	e8 5f ff ff ff       	call   c0103b32 <find_order>
c0103bd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103bd6:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0103bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bdb:	8b 00                	mov    (%eax),%eax
c0103bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103be1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103be4:	89 04 24             	mov    %eax,(%esp)
c0103be7:	e8 ab fb ff ff       	call   c0103797 <__slob_get_free_pages>
c0103bec:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103bef:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0103bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bf5:	8b 40 04             	mov    0x4(%eax),%eax
c0103bf8:	85 c0                	test   %eax,%eax
c0103bfa:	74 2f                	je     c0103c2b <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0103bfc:	e8 4c fa ff ff       	call   c010364d <__intr_save>
c0103c01:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0103c04:	8b 15 e8 d8 11 c0    	mov    0xc011d8e8,%edx
c0103c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c0d:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0103c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c13:	a3 e8 d8 11 c0       	mov    %eax,0xc011d8e8
		spin_unlock_irqrestore(&block_lock, flags);
c0103c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c1b:	89 04 24             	mov    %eax,(%esp)
c0103c1e:	e8 54 fa ff ff       	call   c0103677 <__intr_restore>
		return bb->pages;
c0103c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c26:	8b 40 04             	mov    0x4(%eax),%eax
c0103c29:	eb 18                	jmp    c0103c43 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0103c2b:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0103c32:	00 
c0103c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c36:	89 04 24             	mov    %eax,(%esp)
c0103c39:	e8 9b fd ff ff       	call   c01039d9 <slob_free>
	return 0;
c0103c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103c43:	c9                   	leave  
c0103c44:	c3                   	ret    

c0103c45 <kmalloc>:

void *
kmalloc(size_t size)
{
c0103c45:	55                   	push   %ebp
c0103c46:	89 e5                	mov    %esp,%ebp
c0103c48:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0103c4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103c52:	00 
c0103c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c56:	89 04 24             	mov    %eax,(%esp)
c0103c59:	e8 f8 fe ff ff       	call   c0103b56 <__kmalloc>
}
c0103c5e:	c9                   	leave  
c0103c5f:	c3                   	ret    

c0103c60 <kfree>:


void kfree(void *block)
{
c0103c60:	55                   	push   %ebp
c0103c61:	89 e5                	mov    %esp,%ebp
c0103c63:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0103c66:	c7 45 f0 e8 d8 11 c0 	movl   $0xc011d8e8,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0103c6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c71:	75 05                	jne    c0103c78 <kfree+0x18>
		return;
c0103c73:	e9 a2 00 00 00       	jmp    c0103d1a <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0103c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c7b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103c80:	85 c0                	test   %eax,%eax
c0103c82:	75 7f                	jne    c0103d03 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0103c84:	e8 c4 f9 ff ff       	call   c010364d <__intr_save>
c0103c89:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0103c8c:	a1 e8 d8 11 c0       	mov    0xc011d8e8,%eax
c0103c91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c94:	eb 5c                	jmp    c0103cf2 <kfree+0x92>
			if (bb->pages == block) {
c0103c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c99:	8b 40 04             	mov    0x4(%eax),%eax
c0103c9c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103c9f:	75 3f                	jne    c0103ce0 <kfree+0x80>
				*last = bb->next;
c0103ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca4:	8b 50 08             	mov    0x8(%eax),%edx
c0103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103caa:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0103cac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103caf:	89 04 24             	mov    %eax,(%esp)
c0103cb2:	e8 c0 f9 ff ff       	call   c0103677 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cba:	8b 10                	mov    (%eax),%edx
c0103cbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cbf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cc3:	89 04 24             	mov    %eax,(%esp)
c0103cc6:	e8 05 fb ff ff       	call   c01037d0 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0103ccb:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0103cd2:	00 
c0103cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd6:	89 04 24             	mov    %eax,(%esp)
c0103cd9:	e8 fb fc ff ff       	call   c01039d9 <slob_free>
				return;
c0103cde:	eb 3a                	jmp    c0103d1a <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ce3:	83 c0 08             	add    $0x8,%eax
c0103ce6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cec:	8b 40 08             	mov    0x8(%eax),%eax
c0103cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103cf6:	75 9e                	jne    c0103c96 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0103cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cfb:	89 04 24             	mov    %eax,(%esp)
c0103cfe:	e8 74 f9 ff ff       	call   c0103677 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0103d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d06:	83 e8 08             	sub    $0x8,%eax
c0103d09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103d10:	00 
c0103d11:	89 04 24             	mov    %eax,(%esp)
c0103d14:	e8 c0 fc ff ff       	call   c01039d9 <slob_free>
	return;
c0103d19:	90                   	nop
}
c0103d1a:	c9                   	leave  
c0103d1b:	c3                   	ret    

c0103d1c <ksize>:


unsigned int ksize(const void *block)
{
c0103d1c:	55                   	push   %ebp
c0103d1d:	89 e5                	mov    %esp,%ebp
c0103d1f:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0103d22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103d26:	75 07                	jne    c0103d2f <ksize+0x13>
		return 0;
c0103d28:	b8 00 00 00 00       	mov    $0x0,%eax
c0103d2d:	eb 6b                	jmp    c0103d9a <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0103d2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d32:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103d37:	85 c0                	test   %eax,%eax
c0103d39:	75 54                	jne    c0103d8f <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0103d3b:	e8 0d f9 ff ff       	call   c010364d <__intr_save>
c0103d40:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0103d43:	a1 e8 d8 11 c0       	mov    0xc011d8e8,%eax
c0103d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d4b:	eb 31                	jmp    c0103d7e <ksize+0x62>
			if (bb->pages == block) {
c0103d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d50:	8b 40 04             	mov    0x4(%eax),%eax
c0103d53:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103d56:	75 1d                	jne    c0103d75 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0103d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d5b:	89 04 24             	mov    %eax,(%esp)
c0103d5e:	e8 14 f9 ff ff       	call   c0103677 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d66:	8b 00                	mov    (%eax),%eax
c0103d68:	ba 00 10 00 00       	mov    $0x1000,%edx
c0103d6d:	89 c1                	mov    %eax,%ecx
c0103d6f:	d3 e2                	shl    %cl,%edx
c0103d71:	89 d0                	mov    %edx,%eax
c0103d73:	eb 25                	jmp    c0103d9a <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0103d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d78:	8b 40 08             	mov    0x8(%eax),%eax
c0103d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d82:	75 c9                	jne    c0103d4d <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0103d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d87:	89 04 24             	mov    %eax,(%esp)
c0103d8a:	e8 e8 f8 ff ff       	call   c0103677 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0103d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d92:	83 e8 08             	sub    $0x8,%eax
c0103d95:	8b 00                	mov    (%eax),%eax
c0103d97:	c1 e0 03             	shl    $0x3,%eax
}
c0103d9a:	c9                   	leave  
c0103d9b:	c3                   	ret    

c0103d9c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103d9c:	55                   	push   %ebp
c0103d9d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103d9f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103da2:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0103da7:	29 c2                	sub    %eax,%edx
c0103da9:	89 d0                	mov    %edx,%eax
c0103dab:	c1 f8 05             	sar    $0x5,%eax
}
c0103dae:	5d                   	pop    %ebp
c0103daf:	c3                   	ret    

c0103db0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103db0:	55                   	push   %ebp
c0103db1:	89 e5                	mov    %esp,%ebp
c0103db3:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103db9:	89 04 24             	mov    %eax,(%esp)
c0103dbc:	e8 db ff ff ff       	call   c0103d9c <page2ppn>
c0103dc1:	c1 e0 0c             	shl    $0xc,%eax
}
c0103dc4:	c9                   	leave  
c0103dc5:	c3                   	ret    

c0103dc6 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103dc6:	55                   	push   %ebp
c0103dc7:	89 e5                	mov    %esp,%ebp
c0103dc9:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dcf:	c1 e8 0c             	shr    $0xc,%eax
c0103dd2:	89 c2                	mov    %eax,%edx
c0103dd4:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0103dd9:	39 c2                	cmp    %eax,%edx
c0103ddb:	72 1c                	jb     c0103df9 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103ddd:	c7 44 24 08 00 7d 10 	movl   $0xc0107d00,0x8(%esp)
c0103de4:	c0 
c0103de5:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0103dec:	00 
c0103ded:	c7 04 24 1f 7d 10 c0 	movl   $0xc0107d1f,(%esp)
c0103df4:	e8 64 cd ff ff       	call   c0100b5d <__panic>
    }
    return &pages[PPN(pa)];
c0103df9:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0103dfe:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e01:	c1 ea 0c             	shr    $0xc,%edx
c0103e04:	c1 e2 05             	shl    $0x5,%edx
c0103e07:	01 d0                	add    %edx,%eax
}
c0103e09:	c9                   	leave  
c0103e0a:	c3                   	ret    

c0103e0b <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103e0b:	55                   	push   %ebp
c0103e0c:	89 e5                	mov    %esp,%ebp
c0103e0e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103e11:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e14:	89 04 24             	mov    %eax,(%esp)
c0103e17:	e8 94 ff ff ff       	call   c0103db0 <page2pa>
c0103e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e22:	c1 e8 0c             	shr    $0xc,%eax
c0103e25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e28:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0103e2d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103e30:	72 23                	jb     c0103e55 <page2kva+0x4a>
c0103e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e35:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e39:	c7 44 24 08 30 7d 10 	movl   $0xc0107d30,0x8(%esp)
c0103e40:	c0 
c0103e41:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0103e48:	00 
c0103e49:	c7 04 24 1f 7d 10 c0 	movl   $0xc0107d1f,(%esp)
c0103e50:	e8 08 cd ff ff       	call   c0100b5d <__panic>
c0103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e58:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103e5d:	c9                   	leave  
c0103e5e:	c3                   	ret    

c0103e5f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103e5f:	55                   	push   %ebp
c0103e60:	89 e5                	mov    %esp,%ebp
c0103e62:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e68:	83 e0 01             	and    $0x1,%eax
c0103e6b:	85 c0                	test   %eax,%eax
c0103e6d:	75 1c                	jne    c0103e8b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103e6f:	c7 44 24 08 54 7d 10 	movl   $0xc0107d54,0x8(%esp)
c0103e76:	c0 
c0103e77:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0103e7e:	00 
c0103e7f:	c7 04 24 1f 7d 10 c0 	movl   $0xc0107d1f,(%esp)
c0103e86:	e8 d2 cc ff ff       	call   c0100b5d <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e93:	89 04 24             	mov    %eax,(%esp)
c0103e96:	e8 2b ff ff ff       	call   c0103dc6 <pa2page>
}
c0103e9b:	c9                   	leave  
c0103e9c:	c3                   	ret    

c0103e9d <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103e9d:	55                   	push   %ebp
c0103e9e:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ea3:	8b 00                	mov    (%eax),%eax
}
c0103ea5:	5d                   	pop    %ebp
c0103ea6:	c3                   	ret    

c0103ea7 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103ea7:	55                   	push   %ebp
c0103ea8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ead:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103eb0:	89 10                	mov    %edx,(%eax)
}
c0103eb2:	5d                   	pop    %ebp
c0103eb3:	c3                   	ret    

c0103eb4 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103eb4:	55                   	push   %ebp
c0103eb5:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103eb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eba:	8b 00                	mov    (%eax),%eax
c0103ebc:	8d 50 01             	lea    0x1(%eax),%edx
c0103ebf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ec2:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103ec4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ec7:	8b 00                	mov    (%eax),%eax
}
c0103ec9:	5d                   	pop    %ebp
c0103eca:	c3                   	ret    

c0103ecb <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103ecb:	55                   	push   %ebp
c0103ecc:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103ece:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ed1:	8b 00                	mov    (%eax),%eax
c0103ed3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103ed6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ed9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ede:	8b 00                	mov    (%eax),%eax
}
c0103ee0:	5d                   	pop    %ebp
c0103ee1:	c3                   	ret    

c0103ee2 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103ee2:	55                   	push   %ebp
c0103ee3:	89 e5                	mov    %esp,%ebp
c0103ee5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103ee8:	9c                   	pushf  
c0103ee9:	58                   	pop    %eax
c0103eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103ef0:	25 00 02 00 00       	and    $0x200,%eax
c0103ef5:	85 c0                	test   %eax,%eax
c0103ef7:	74 0c                	je     c0103f05 <__intr_save+0x23>
        intr_disable();
c0103ef9:	e8 42 d6 ff ff       	call   c0101540 <intr_disable>
        return 1;
c0103efe:	b8 01 00 00 00       	mov    $0x1,%eax
c0103f03:	eb 05                	jmp    c0103f0a <__intr_save+0x28>
    }
    return 0;
c0103f05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103f0a:	c9                   	leave  
c0103f0b:	c3                   	ret    

c0103f0c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103f0c:	55                   	push   %ebp
c0103f0d:	89 e5                	mov    %esp,%ebp
c0103f0f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103f12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103f16:	74 05                	je     c0103f1d <__intr_restore+0x11>
        intr_enable();
c0103f18:	e8 1d d6 ff ff       	call   c010153a <intr_enable>
    }
}
c0103f1d:	c9                   	leave  
c0103f1e:	c3                   	ret    

c0103f1f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103f1f:	55                   	push   %ebp
c0103f20:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103f22:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f25:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103f28:	b8 23 00 00 00       	mov    $0x23,%eax
c0103f2d:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103f2f:	b8 23 00 00 00       	mov    $0x23,%eax
c0103f34:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103f36:	b8 10 00 00 00       	mov    $0x10,%eax
c0103f3b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103f3d:	b8 10 00 00 00       	mov    $0x10,%eax
c0103f42:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103f44:	b8 10 00 00 00       	mov    $0x10,%eax
c0103f49:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103f4b:	ea 52 3f 10 c0 08 00 	ljmp   $0x8,$0xc0103f52
}
c0103f52:	5d                   	pop    %ebp
c0103f53:	c3                   	ret    

c0103f54 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103f54:	55                   	push   %ebp
c0103f55:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103f57:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f5a:	a3 24 d9 11 c0       	mov    %eax,0xc011d924
}
c0103f5f:	5d                   	pop    %ebp
c0103f60:	c3                   	ret    

c0103f61 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103f61:	55                   	push   %ebp
c0103f62:	89 e5                	mov    %esp,%ebp
c0103f64:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103f67:	b8 00 c0 11 c0       	mov    $0xc011c000,%eax
c0103f6c:	89 04 24             	mov    %eax,(%esp)
c0103f6f:	e8 e0 ff ff ff       	call   c0103f54 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103f74:	66 c7 05 28 d9 11 c0 	movw   $0x10,0xc011d928
c0103f7b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103f7d:	66 c7 05 48 ca 11 c0 	movw   $0x68,0xc011ca48
c0103f84:	68 00 
c0103f86:	b8 20 d9 11 c0       	mov    $0xc011d920,%eax
c0103f8b:	66 a3 4a ca 11 c0    	mov    %ax,0xc011ca4a
c0103f91:	b8 20 d9 11 c0       	mov    $0xc011d920,%eax
c0103f96:	c1 e8 10             	shr    $0x10,%eax
c0103f99:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c0103f9e:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0103fa5:	83 e0 f0             	and    $0xfffffff0,%eax
c0103fa8:	83 c8 09             	or     $0x9,%eax
c0103fab:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0103fb0:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0103fb7:	83 e0 ef             	and    $0xffffffef,%eax
c0103fba:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0103fbf:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0103fc6:	83 e0 9f             	and    $0xffffff9f,%eax
c0103fc9:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0103fce:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0103fd5:	83 c8 80             	or     $0xffffff80,%eax
c0103fd8:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0103fdd:	0f b6 05 4e ca 11 c0 	movzbl 0xc011ca4e,%eax
c0103fe4:	83 e0 f0             	and    $0xfffffff0,%eax
c0103fe7:	a2 4e ca 11 c0       	mov    %al,0xc011ca4e
c0103fec:	0f b6 05 4e ca 11 c0 	movzbl 0xc011ca4e,%eax
c0103ff3:	83 e0 ef             	and    $0xffffffef,%eax
c0103ff6:	a2 4e ca 11 c0       	mov    %al,0xc011ca4e
c0103ffb:	0f b6 05 4e ca 11 c0 	movzbl 0xc011ca4e,%eax
c0104002:	83 e0 df             	and    $0xffffffdf,%eax
c0104005:	a2 4e ca 11 c0       	mov    %al,0xc011ca4e
c010400a:	0f b6 05 4e ca 11 c0 	movzbl 0xc011ca4e,%eax
c0104011:	83 c8 40             	or     $0x40,%eax
c0104014:	a2 4e ca 11 c0       	mov    %al,0xc011ca4e
c0104019:	0f b6 05 4e ca 11 c0 	movzbl 0xc011ca4e,%eax
c0104020:	83 e0 7f             	and    $0x7f,%eax
c0104023:	a2 4e ca 11 c0       	mov    %al,0xc011ca4e
c0104028:	b8 20 d9 11 c0       	mov    $0xc011d920,%eax
c010402d:	c1 e8 18             	shr    $0x18,%eax
c0104030:	a2 4f ca 11 c0       	mov    %al,0xc011ca4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104035:	c7 04 24 50 ca 11 c0 	movl   $0xc011ca50,(%esp)
c010403c:	e8 de fe ff ff       	call   c0103f1f <lgdt>
c0104041:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104047:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010404b:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c010404e:	c9                   	leave  
c010404f:	c3                   	ret    

c0104050 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104050:	55                   	push   %ebp
c0104051:	89 e5                	mov    %esp,%ebp
c0104053:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104056:	c7 05 c4 d9 11 c0 f4 	movl   $0xc0107bf4,0xc011d9c4
c010405d:	7b 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104060:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c0104065:	8b 00                	mov    (%eax),%eax
c0104067:	89 44 24 04          	mov    %eax,0x4(%esp)
c010406b:	c7 04 24 80 7d 10 c0 	movl   $0xc0107d80,(%esp)
c0104072:	e8 50 c1 ff ff       	call   c01001c7 <cprintf>
    pmm_manager->init();
c0104077:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c010407c:	8b 40 04             	mov    0x4(%eax),%eax
c010407f:	ff d0                	call   *%eax
}
c0104081:	c9                   	leave  
c0104082:	c3                   	ret    

c0104083 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104083:	55                   	push   %ebp
c0104084:	89 e5                	mov    %esp,%ebp
c0104086:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104089:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c010408e:	8b 40 08             	mov    0x8(%eax),%eax
c0104091:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104094:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104098:	8b 55 08             	mov    0x8(%ebp),%edx
c010409b:	89 14 24             	mov    %edx,(%esp)
c010409e:	ff d0                	call   *%eax
}
c01040a0:	c9                   	leave  
c01040a1:	c3                   	ret    

c01040a2 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01040a2:	55                   	push   %ebp
c01040a3:	89 e5                	mov    %esp,%ebp
c01040a5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01040a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
  
    local_intr_save(intr_flag);
c01040af:	e8 2e fe ff ff       	call   c0103ee2 <__intr_save>
c01040b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    page = pmm_manager->alloc_pages(n);
c01040b7:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c01040bc:	8b 40 0c             	mov    0xc(%eax),%eax
c01040bf:	8b 55 08             	mov    0x8(%ebp),%edx
c01040c2:	89 14 24             	mov    %edx,(%esp)
c01040c5:	ff d0                	call   *%eax
c01040c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    local_intr_restore(intr_flag);
c01040ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040cd:	89 04 24             	mov    %eax,(%esp)
c01040d0:	e8 37 fe ff ff       	call   c0103f0c <__intr_restore>

    if (page == NULL )
c01040d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01040d9:	75 1c                	jne    c01040f7 <alloc_pages+0x55>
       panic("alloc_pages: NO FREE PAGES!!!\n");       
c01040db:	c7 44 24 08 98 7d 10 	movl   $0xc0107d98,0x8(%esp)
c01040e2:	c0 
c01040e3:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c01040ea:	00 
c01040eb:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01040f2:	e8 66 ca ff ff       	call   c0100b5d <__panic>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01040f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01040fa:	c9                   	leave  
c01040fb:	c3                   	ret    

c01040fc <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01040fc:	55                   	push   %ebp
c01040fd:	89 e5                	mov    %esp,%ebp
c01040ff:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104102:	e8 db fd ff ff       	call   c0103ee2 <__intr_save>
c0104107:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c010410a:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c010410f:	8b 40 10             	mov    0x10(%eax),%eax
c0104112:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104115:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104119:	8b 55 08             	mov    0x8(%ebp),%edx
c010411c:	89 14 24             	mov    %edx,(%esp)
c010411f:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104124:	89 04 24             	mov    %eax,(%esp)
c0104127:	e8 e0 fd ff ff       	call   c0103f0c <__intr_restore>
}
c010412c:	c9                   	leave  
c010412d:	c3                   	ret    

c010412e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010412e:	55                   	push   %ebp
c010412f:	89 e5                	mov    %esp,%ebp
c0104131:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104134:	e8 a9 fd ff ff       	call   c0103ee2 <__intr_save>
c0104139:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010413c:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c0104141:	8b 40 14             	mov    0x14(%eax),%eax
c0104144:	ff d0                	call   *%eax
c0104146:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104149:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010414c:	89 04 24             	mov    %eax,(%esp)
c010414f:	e8 b8 fd ff ff       	call   c0103f0c <__intr_restore>
    return ret;
c0104154:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104157:	c9                   	leave  
c0104158:	c3                   	ret    

c0104159 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104159:	55                   	push   %ebp
c010415a:	89 e5                	mov    %esp,%ebp
c010415c:	57                   	push   %edi
c010415d:	56                   	push   %esi
c010415e:	53                   	push   %ebx
c010415f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104165:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010416c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104173:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010417a:	c7 04 24 c5 7d 10 c0 	movl   $0xc0107dc5,(%esp)
c0104181:	e8 41 c0 ff ff       	call   c01001c7 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104186:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010418d:	e9 15 01 00 00       	jmp    c01042a7 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104192:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104195:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104198:	89 d0                	mov    %edx,%eax
c010419a:	c1 e0 02             	shl    $0x2,%eax
c010419d:	01 d0                	add    %edx,%eax
c010419f:	c1 e0 02             	shl    $0x2,%eax
c01041a2:	01 c8                	add    %ecx,%eax
c01041a4:	8b 50 08             	mov    0x8(%eax),%edx
c01041a7:	8b 40 04             	mov    0x4(%eax),%eax
c01041aa:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01041ad:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01041b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01041b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041b6:	89 d0                	mov    %edx,%eax
c01041b8:	c1 e0 02             	shl    $0x2,%eax
c01041bb:	01 d0                	add    %edx,%eax
c01041bd:	c1 e0 02             	shl    $0x2,%eax
c01041c0:	01 c8                	add    %ecx,%eax
c01041c2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01041c5:	8b 58 10             	mov    0x10(%eax),%ebx
c01041c8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01041cb:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01041ce:	01 c8                	add    %ecx,%eax
c01041d0:	11 da                	adc    %ebx,%edx
c01041d2:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01041d5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01041d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01041db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041de:	89 d0                	mov    %edx,%eax
c01041e0:	c1 e0 02             	shl    $0x2,%eax
c01041e3:	01 d0                	add    %edx,%eax
c01041e5:	c1 e0 02             	shl    $0x2,%eax
c01041e8:	01 c8                	add    %ecx,%eax
c01041ea:	83 c0 14             	add    $0x14,%eax
c01041ed:	8b 00                	mov    (%eax),%eax
c01041ef:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01041f5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01041f8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01041fb:	83 c0 ff             	add    $0xffffffff,%eax
c01041fe:	83 d2 ff             	adc    $0xffffffff,%edx
c0104201:	89 c6                	mov    %eax,%esi
c0104203:	89 d7                	mov    %edx,%edi
c0104205:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104208:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010420b:	89 d0                	mov    %edx,%eax
c010420d:	c1 e0 02             	shl    $0x2,%eax
c0104210:	01 d0                	add    %edx,%eax
c0104212:	c1 e0 02             	shl    $0x2,%eax
c0104215:	01 c8                	add    %ecx,%eax
c0104217:	8b 48 0c             	mov    0xc(%eax),%ecx
c010421a:	8b 58 10             	mov    0x10(%eax),%ebx
c010421d:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104223:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104227:	89 74 24 14          	mov    %esi,0x14(%esp)
c010422b:	89 7c 24 18          	mov    %edi,0x18(%esp)
c010422f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104232:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104235:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104239:	89 54 24 10          	mov    %edx,0x10(%esp)
c010423d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104241:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104245:	c7 04 24 d0 7d 10 c0 	movl   $0xc0107dd0,(%esp)
c010424c:	e8 76 bf ff ff       	call   c01001c7 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104251:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104254:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104257:	89 d0                	mov    %edx,%eax
c0104259:	c1 e0 02             	shl    $0x2,%eax
c010425c:	01 d0                	add    %edx,%eax
c010425e:	c1 e0 02             	shl    $0x2,%eax
c0104261:	01 c8                	add    %ecx,%eax
c0104263:	83 c0 14             	add    $0x14,%eax
c0104266:	8b 00                	mov    (%eax),%eax
c0104268:	83 f8 01             	cmp    $0x1,%eax
c010426b:	75 36                	jne    c01042a3 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c010426d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104270:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104273:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104276:	77 2b                	ja     c01042a3 <page_init+0x14a>
c0104278:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010427b:	72 05                	jb     c0104282 <page_init+0x129>
c010427d:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0104280:	73 21                	jae    c01042a3 <page_init+0x14a>
c0104282:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104286:	77 1b                	ja     c01042a3 <page_init+0x14a>
c0104288:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010428c:	72 09                	jb     c0104297 <page_init+0x13e>
c010428e:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0104295:	77 0c                	ja     c01042a3 <page_init+0x14a>
                maxpa = end;
c0104297:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010429a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010429d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01042a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01042a3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01042a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01042aa:	8b 00                	mov    (%eax),%eax
c01042ac:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01042af:	0f 8f dd fe ff ff    	jg     c0104192 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01042b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01042b9:	72 1d                	jb     c01042d8 <page_init+0x17f>
c01042bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01042bf:	77 09                	ja     c01042ca <page_init+0x171>
c01042c1:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01042c8:	76 0e                	jbe    c01042d8 <page_init+0x17f>
        maxpa = KMEMSIZE;
c01042ca:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01042d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01042d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01042de:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01042e2:	c1 ea 0c             	shr    $0xc,%edx
c01042e5:	a3 00 d9 11 c0       	mov    %eax,0xc011d900
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01042ea:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01042f1:	b8 d8 d9 11 c0       	mov    $0xc011d9d8,%eax
c01042f6:	8d 50 ff             	lea    -0x1(%eax),%edx
c01042f9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01042fc:	01 d0                	add    %edx,%eax
c01042fe:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104301:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104304:	ba 00 00 00 00       	mov    $0x0,%edx
c0104309:	f7 75 ac             	divl   -0x54(%ebp)
c010430c:	89 d0                	mov    %edx,%eax
c010430e:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104311:	29 c2                	sub    %eax,%edx
c0104313:	89 d0                	mov    %edx,%eax
c0104315:	a3 cc d9 11 c0       	mov    %eax,0xc011d9cc

    for (i = 0; i < npage; i ++) {
c010431a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104321:	eb 27                	jmp    c010434a <page_init+0x1f1>
        SetPageReserved(pages + i);
c0104323:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0104328:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010432b:	c1 e2 05             	shl    $0x5,%edx
c010432e:	01 d0                	add    %edx,%eax
c0104330:	83 c0 04             	add    $0x4,%eax
c0104333:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c010433a:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010433d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104340:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104343:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104346:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010434a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010434d:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0104352:	39 c2                	cmp    %eax,%edx
c0104354:	72 cd                	jb     c0104323 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104356:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c010435b:	c1 e0 05             	shl    $0x5,%eax
c010435e:	89 c2                	mov    %eax,%edx
c0104360:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0104365:	01 d0                	add    %edx,%eax
c0104367:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010436a:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104371:	77 23                	ja     c0104396 <page_init+0x23d>
c0104373:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104376:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010437a:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0104381:	c0 
c0104382:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104389:	00 
c010438a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104391:	e8 c7 c7 ff ff       	call   c0100b5d <__panic>
c0104396:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104399:	05 00 00 00 40       	add    $0x40000000,%eax
c010439e:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01043a1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01043a8:	e9 74 01 00 00       	jmp    c0104521 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01043ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01043b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043b3:	89 d0                	mov    %edx,%eax
c01043b5:	c1 e0 02             	shl    $0x2,%eax
c01043b8:	01 d0                	add    %edx,%eax
c01043ba:	c1 e0 02             	shl    $0x2,%eax
c01043bd:	01 c8                	add    %ecx,%eax
c01043bf:	8b 50 08             	mov    0x8(%eax),%edx
c01043c2:	8b 40 04             	mov    0x4(%eax),%eax
c01043c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01043c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01043cb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01043ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043d1:	89 d0                	mov    %edx,%eax
c01043d3:	c1 e0 02             	shl    $0x2,%eax
c01043d6:	01 d0                	add    %edx,%eax
c01043d8:	c1 e0 02             	shl    $0x2,%eax
c01043db:	01 c8                	add    %ecx,%eax
c01043dd:	8b 48 0c             	mov    0xc(%eax),%ecx
c01043e0:	8b 58 10             	mov    0x10(%eax),%ebx
c01043e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043e9:	01 c8                	add    %ecx,%eax
c01043eb:	11 da                	adc    %ebx,%edx
c01043ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01043f0:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01043f3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01043f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043f9:	89 d0                	mov    %edx,%eax
c01043fb:	c1 e0 02             	shl    $0x2,%eax
c01043fe:	01 d0                	add    %edx,%eax
c0104400:	c1 e0 02             	shl    $0x2,%eax
c0104403:	01 c8                	add    %ecx,%eax
c0104405:	83 c0 14             	add    $0x14,%eax
c0104408:	8b 00                	mov    (%eax),%eax
c010440a:	83 f8 01             	cmp    $0x1,%eax
c010440d:	0f 85 0a 01 00 00    	jne    c010451d <page_init+0x3c4>
            if (begin < freemem) {
c0104413:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104416:	ba 00 00 00 00       	mov    $0x0,%edx
c010441b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010441e:	72 17                	jb     c0104437 <page_init+0x2de>
c0104420:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104423:	77 05                	ja     c010442a <page_init+0x2d1>
c0104425:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104428:	76 0d                	jbe    c0104437 <page_init+0x2de>
                begin = freemem;
c010442a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010442d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104430:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104437:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010443b:	72 1d                	jb     c010445a <page_init+0x301>
c010443d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104441:	77 09                	ja     c010444c <page_init+0x2f3>
c0104443:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010444a:	76 0e                	jbe    c010445a <page_init+0x301>
                end = KMEMSIZE;
c010444c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104453:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010445a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010445d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104460:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104463:	0f 87 b4 00 00 00    	ja     c010451d <page_init+0x3c4>
c0104469:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010446c:	72 09                	jb     c0104477 <page_init+0x31e>
c010446e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104471:	0f 83 a6 00 00 00    	jae    c010451d <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0104477:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010447e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104481:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104484:	01 d0                	add    %edx,%eax
c0104486:	83 e8 01             	sub    $0x1,%eax
c0104489:	89 45 98             	mov    %eax,-0x68(%ebp)
c010448c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010448f:	ba 00 00 00 00       	mov    $0x0,%edx
c0104494:	f7 75 9c             	divl   -0x64(%ebp)
c0104497:	89 d0                	mov    %edx,%eax
c0104499:	8b 55 98             	mov    -0x68(%ebp),%edx
c010449c:	29 c2                	sub    %eax,%edx
c010449e:	89 d0                	mov    %edx,%eax
c01044a0:	ba 00 00 00 00       	mov    $0x0,%edx
c01044a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01044a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01044ab:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01044ae:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01044b1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01044b4:	ba 00 00 00 00       	mov    $0x0,%edx
c01044b9:	89 c7                	mov    %eax,%edi
c01044bb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01044c1:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01044c4:	89 d0                	mov    %edx,%eax
c01044c6:	83 e0 00             	and    $0x0,%eax
c01044c9:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01044cc:	8b 45 80             	mov    -0x80(%ebp),%eax
c01044cf:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01044d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01044d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01044d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01044db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01044de:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01044e1:	77 3a                	ja     c010451d <page_init+0x3c4>
c01044e3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01044e6:	72 05                	jb     c01044ed <page_init+0x394>
c01044e8:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01044eb:	73 30                	jae    c010451d <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01044ed:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01044f0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01044f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01044f6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01044f9:	29 c8                	sub    %ecx,%eax
c01044fb:	19 da                	sbb    %ebx,%edx
c01044fd:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104501:	c1 ea 0c             	shr    $0xc,%edx
c0104504:	89 c3                	mov    %eax,%ebx
c0104506:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104509:	89 04 24             	mov    %eax,(%esp)
c010450c:	e8 b5 f8 ff ff       	call   c0103dc6 <pa2page>
c0104511:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104515:	89 04 24             	mov    %eax,(%esp)
c0104518:	e8 66 fb ff ff       	call   c0104083 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010451d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104521:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104524:	8b 00                	mov    (%eax),%eax
c0104526:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104529:	0f 8f 7e fe ff ff    	jg     c01043ad <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c010452f:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104535:	5b                   	pop    %ebx
c0104536:	5e                   	pop    %esi
c0104537:	5f                   	pop    %edi
c0104538:	5d                   	pop    %ebp
c0104539:	c3                   	ret    

c010453a <enable_paging>:

static void
enable_paging(void) {
c010453a:	55                   	push   %ebp
c010453b:	89 e5                	mov    %esp,%ebp
c010453d:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c0104540:	a1 c8 d9 11 c0       	mov    0xc011d9c8,%eax
c0104545:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0104548:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010454b:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c010454e:	0f 20 c0             	mov    %cr0,%eax
c0104551:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c0104554:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c0104557:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c010455a:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0104561:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0104565:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104568:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c010456b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010456e:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0104571:	c9                   	leave  
c0104572:	c3                   	ret    

c0104573 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104573:	55                   	push   %ebp
c0104574:	89 e5                	mov    %esp,%ebp
c0104576:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104579:	8b 45 14             	mov    0x14(%ebp),%eax
c010457c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010457f:	31 d0                	xor    %edx,%eax
c0104581:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104586:	85 c0                	test   %eax,%eax
c0104588:	74 24                	je     c01045ae <boot_map_segment+0x3b>
c010458a:	c7 44 24 0c 24 7e 10 	movl   $0xc0107e24,0xc(%esp)
c0104591:	c0 
c0104592:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104599:	c0 
c010459a:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01045a1:	00 
c01045a2:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01045a9:	e8 af c5 ff ff       	call   c0100b5d <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01045ae:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01045b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045b8:	25 ff 0f 00 00       	and    $0xfff,%eax
c01045bd:	89 c2                	mov    %eax,%edx
c01045bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01045c2:	01 c2                	add    %eax,%edx
c01045c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045c7:	01 d0                	add    %edx,%eax
c01045c9:	83 e8 01             	sub    $0x1,%eax
c01045cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01045cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045d2:	ba 00 00 00 00       	mov    $0x0,%edx
c01045d7:	f7 75 f0             	divl   -0x10(%ebp)
c01045da:	89 d0                	mov    %edx,%eax
c01045dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01045df:	29 c2                	sub    %eax,%edx
c01045e1:	89 d0                	mov    %edx,%eax
c01045e3:	c1 e8 0c             	shr    $0xc,%eax
c01045e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01045e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01045ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01045f7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01045fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01045fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104603:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104608:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010460b:	eb 6b                	jmp    c0104678 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010460d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104614:	00 
c0104615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104618:	89 44 24 04          	mov    %eax,0x4(%esp)
c010461c:	8b 45 08             	mov    0x8(%ebp),%eax
c010461f:	89 04 24             	mov    %eax,(%esp)
c0104622:	e8 d1 01 00 00       	call   c01047f8 <get_pte>
c0104627:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010462a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010462e:	75 24                	jne    c0104654 <boot_map_segment+0xe1>
c0104630:	c7 44 24 0c 50 7e 10 	movl   $0xc0107e50,0xc(%esp)
c0104637:	c0 
c0104638:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c010463f:	c0 
c0104640:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0104647:	00 
c0104648:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c010464f:	e8 09 c5 ff ff       	call   c0100b5d <__panic>
        *ptep = pa | PTE_P | perm;
c0104654:	8b 45 18             	mov    0x18(%ebp),%eax
c0104657:	8b 55 14             	mov    0x14(%ebp),%edx
c010465a:	09 d0                	or     %edx,%eax
c010465c:	83 c8 01             	or     $0x1,%eax
c010465f:	89 c2                	mov    %eax,%edx
c0104661:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104664:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104666:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010466a:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104671:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104678:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010467c:	75 8f                	jne    c010460d <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010467e:	c9                   	leave  
c010467f:	c3                   	ret    

c0104680 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104680:	55                   	push   %ebp
c0104681:	89 e5                	mov    %esp,%ebp
c0104683:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010468d:	e8 10 fa ff ff       	call   c01040a2 <alloc_pages>
c0104692:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104695:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104699:	75 1c                	jne    c01046b7 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010469b:	c7 44 24 08 5d 7e 10 	movl   $0xc0107e5d,0x8(%esp)
c01046a2:	c0 
c01046a3:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01046aa:	00 
c01046ab:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01046b2:	e8 a6 c4 ff ff       	call   c0100b5d <__panic>
    }
    return page2kva(p);
c01046b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ba:	89 04 24             	mov    %eax,(%esp)
c01046bd:	e8 49 f7 ff ff       	call   c0103e0b <page2kva>
}
c01046c2:	c9                   	leave  
c01046c3:	c3                   	ret    

c01046c4 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01046c4:	55                   	push   %ebp
c01046c5:	89 e5                	mov    %esp,%ebp
c01046c7:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01046ca:	e8 81 f9 ff ff       	call   c0104050 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01046cf:	e8 85 fa ff ff       	call   c0104159 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01046d4:	e8 46 05 00 00       	call   c0104c1f <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c01046d9:	e8 a2 ff ff ff       	call   c0104680 <boot_alloc_page>
c01046de:	a3 04 d9 11 c0       	mov    %eax,0xc011d904
    memset(boot_pgdir, 0, PGSIZE);
c01046e3:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01046e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01046ef:	00 
c01046f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01046f7:	00 
c01046f8:	89 04 24             	mov    %eax,(%esp)
c01046fb:	e8 29 2a 00 00       	call   c0107129 <memset>
    boot_cr3 = PADDR(boot_pgdir);
c0104700:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104705:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104708:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010470f:	77 23                	ja     c0104734 <pmm_init+0x70>
c0104711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104714:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104718:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c010471f:	c0 
c0104720:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104727:	00 
c0104728:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c010472f:	e8 29 c4 ff ff       	call   c0100b5d <__panic>
c0104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104737:	05 00 00 00 40       	add    $0x40000000,%eax
c010473c:	a3 c8 d9 11 c0       	mov    %eax,0xc011d9c8

    check_pgdir();
c0104741:	e8 f7 04 00 00       	call   c0104c3d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104746:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c010474b:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104751:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104756:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104759:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104760:	77 23                	ja     c0104785 <pmm_init+0xc1>
c0104762:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104765:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104769:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0104770:	c0 
c0104771:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0104778:	00 
c0104779:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104780:	e8 d8 c3 ff ff       	call   c0100b5d <__panic>
c0104785:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104788:	05 00 00 00 40       	add    $0x40000000,%eax
c010478d:	83 c8 03             	or     $0x3,%eax
c0104790:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104792:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104797:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010479e:	00 
c010479f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01047a6:	00 
c01047a7:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01047ae:	38 
c01047af:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01047b6:	c0 
c01047b7:	89 04 24             	mov    %eax,(%esp)
c01047ba:	e8 b4 fd ff ff       	call   c0104573 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c01047bf:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01047c4:	8b 15 04 d9 11 c0    	mov    0xc011d904,%edx
c01047ca:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c01047d0:	89 10                	mov    %edx,(%eax)

    enable_paging();
c01047d2:	e8 63 fd ff ff       	call   c010453a <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01047d7:	e8 85 f7 ff ff       	call   c0103f61 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c01047dc:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01047e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01047e7:	e8 ec 0a 00 00       	call   c01052d8 <check_boot_pgdir>

    print_pgdir();
c01047ec:	e8 79 0f 00 00       	call   c010576a <print_pgdir>
    
    kmalloc_init();
c01047f1:	e8 0f f3 ff ff       	call   c0103b05 <kmalloc_init>

}
c01047f6:	c9                   	leave  
c01047f7:	c3                   	ret    

c01047f8 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01047f8:	55                   	push   %ebp
c01047f9:	89 e5                	mov    %esp,%ebp
c01047fb:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    // (1) find page directory entry
    pde_t *pdep = pgdir + PDX(la);
c01047fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104801:	c1 e8 16             	shr    $0x16,%eax
c0104804:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010480b:	8b 45 08             	mov    0x8(%ebp),%eax
c010480e:	01 d0                	add    %edx,%eax
c0104810:	89 45 f4             	mov    %eax,-0xc(%ebp)
    pte_t *ret = NULL;
c0104813:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    // (2) check if entry is not present
    if (!(*pdep & PTE_P)) {
c010481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010481d:	8b 00                	mov    (%eax),%eax
c010481f:	83 e0 01             	and    $0x1,%eax
c0104822:	85 c0                	test   %eax,%eax
c0104824:	0f 85 d9 00 00 00    	jne    c0104903 <get_pte+0x10b>
        // (3) check if creating is needed, then alloc page for page table
        if (!create)
c010482a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010482e:	75 0a                	jne    c010483a <get_pte+0x42>
            return NULL;
c0104830:	b8 00 00 00 00       	mov    $0x0,%eax
c0104835:	e9 2e 01 00 00       	jmp    c0104968 <get_pte+0x170>
        // CAUTION: this page is used for page table, not for common data page
        struct Page *page = alloc_page();
c010483a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104841:	e8 5c f8 ff ff       	call   c01040a2 <alloc_pages>
c0104846:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // (4) set page reference
        set_page_ref(page, 1);
c0104849:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104850:	00 
c0104851:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104854:	89 04 24             	mov    %eax,(%esp)
c0104857:	e8 4b f6 ff ff       	call   c0103ea7 <set_page_ref>
        // (5) get linear address of page
        uintptr_t pa = page2pa(page); //physical
c010485c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010485f:	89 04 24             	mov    %eax,(%esp)
c0104862:	e8 49 f5 ff ff       	call   c0103db0 <page2pa>
c0104867:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // (6) clear page content using memset
        memset((void*)KADDR(pa), 0, PGSIZE);
c010486a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010486d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104870:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104873:	c1 e8 0c             	shr    $0xc,%eax
c0104876:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104879:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c010487e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104881:	72 23                	jb     c01048a6 <get_pte+0xae>
c0104883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104886:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010488a:	c7 44 24 08 30 7d 10 	movl   $0xc0107d30,0x8(%esp)
c0104891:	c0 
c0104892:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c0104899:	00 
c010489a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01048a1:	e8 b7 c2 ff ff       	call   c0100b5d <__panic>
c01048a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048a9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01048ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01048b5:	00 
c01048b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048bd:	00 
c01048be:	89 04 24             	mov    %eax,(%esp)
c01048c1:	e8 63 28 00 00       	call   c0107129 <memset>
        // (7) set page directory entry's permission
        assert(!(pa & 0xFFF));
c01048c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048c9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01048ce:	85 c0                	test   %eax,%eax
c01048d0:	74 24                	je     c01048f6 <get_pte+0xfe>
c01048d2:	c7 44 24 0c 76 7e 10 	movl   $0xc0107e76,0xc(%esp)
c01048d9:	c0 
c01048da:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01048e1:	c0 
c01048e2:	c7 44 24 04 8c 01 00 	movl   $0x18c,0x4(%esp)
c01048e9:	00 
c01048ea:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01048f1:	e8 67 c2 ff ff       	call   c0100b5d <__panic>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01048f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048f9:	83 c8 07             	or     $0x7,%eax
c01048fc:	89 c2                	mov    %eax,%edx
c01048fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104901:	89 10                	mov    %edx,(%eax)
    }
    ret = KADDR((pte_t *)(*pdep & ~0xFFF) + PTX(la));
c0104903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104906:	c1 e8 0c             	shr    $0xc,%eax
c0104909:	25 ff 03 00 00       	and    $0x3ff,%eax
c010490e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104918:	8b 00                	mov    (%eax),%eax
c010491a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010491f:	01 d0                	add    %edx,%eax
c0104921:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104924:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104927:	c1 e8 0c             	shr    $0xc,%eax
c010492a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010492d:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0104932:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104935:	72 23                	jb     c010495a <get_pte+0x162>
c0104937:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010493a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010493e:	c7 44 24 08 30 7d 10 	movl   $0xc0107d30,0x8(%esp)
c0104945:	c0 
c0104946:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c010494d:	00 
c010494e:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104955:	e8 03 c2 ff ff       	call   c0100b5d <__panic>
c010495a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010495d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104962:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return ret;          // (8) return page table entry
c0104965:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104968:	c9                   	leave  
c0104969:	c3                   	ret    

c010496a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010496a:	55                   	push   %ebp
c010496b:	89 e5                	mov    %esp,%ebp
c010496d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104970:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104977:	00 
c0104978:	8b 45 0c             	mov    0xc(%ebp),%eax
c010497b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010497f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104982:	89 04 24             	mov    %eax,(%esp)
c0104985:	e8 6e fe ff ff       	call   c01047f8 <get_pte>
c010498a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010498d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104991:	74 08                	je     c010499b <get_page+0x31>
        *ptep_store = ptep;
c0104993:	8b 45 10             	mov    0x10(%ebp),%eax
c0104996:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104999:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010499b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010499f:	74 1b                	je     c01049bc <get_page+0x52>
c01049a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a4:	8b 00                	mov    (%eax),%eax
c01049a6:	83 e0 01             	and    $0x1,%eax
c01049a9:	85 c0                	test   %eax,%eax
c01049ab:	74 0f                	je     c01049bc <get_page+0x52>
        return pa2page(*ptep);
c01049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b0:	8b 00                	mov    (%eax),%eax
c01049b2:	89 04 24             	mov    %eax,(%esp)
c01049b5:	e8 0c f4 ff ff       	call   c0103dc6 <pa2page>
c01049ba:	eb 05                	jmp    c01049c1 <get_page+0x57>
    }
    return NULL;
c01049bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01049c1:	c9                   	leave  
c01049c2:	c3                   	ret    

c01049c3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01049c3:	55                   	push   %ebp
c01049c4:	89 e5                	mov    %esp,%ebp
c01049c6:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    //(1) check if this page table entry is present
    if (*ptep & PTE_P) {
c01049c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01049cc:	8b 00                	mov    (%eax),%eax
c01049ce:	83 e0 01             	and    $0x1,%eax
c01049d1:	85 c0                	test   %eax,%eax
c01049d3:	74 68                	je     c0104a3d <page_remove_pte+0x7a>
        //(2) find corresponding page to pte
        struct Page *page = pte2page(*ptep);
c01049d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01049d8:	8b 00                	mov    (%eax),%eax
c01049da:	89 04 24             	mov    %eax,(%esp)
c01049dd:	e8 7d f4 ff ff       	call   c0103e5f <pte2page>
c01049e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        //(3) decrease page reference
        assert(page->ref > 0);
c01049e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e8:	8b 00                	mov    (%eax),%eax
c01049ea:	85 c0                	test   %eax,%eax
c01049ec:	7f 24                	jg     c0104a12 <page_remove_pte+0x4f>
c01049ee:	c7 44 24 0c 84 7e 10 	movl   $0xc0107e84,0xc(%esp)
c01049f5:	c0 
c01049f6:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01049fd:	c0 
c01049fe:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
c0104a05:	00 
c0104a06:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104a0d:	e8 4b c1 ff ff       	call   c0100b5d <__panic>
        if (!page_ref_dec(page)) {
c0104a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a15:	89 04 24             	mov    %eax,(%esp)
c0104a18:	e8 ae f4 ff ff       	call   c0103ecb <page_ref_dec>
c0104a1d:	85 c0                	test   %eax,%eax
c0104a1f:	75 13                	jne    c0104a34 <page_remove_pte+0x71>
            //(4) and free this page when page reference reachs 0
            free_page(page);
c0104a21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a28:	00 
c0104a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a2c:	89 04 24             	mov    %eax,(%esp)
c0104a2f:	e8 c8 f6 ff ff       	call   c01040fc <free_pages>
        }
        //(5) clear second page table entry
        *ptep = 0;
c0104a34:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        //(6) flush tlb
    }
    tlb_invalidate(pgdir, la);
c0104a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a44:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a47:	89 04 24             	mov    %eax,(%esp)
c0104a4a:	e8 ff 00 00 00       	call   c0104b4e <tlb_invalidate>
}
c0104a4f:	c9                   	leave  
c0104a50:	c3                   	ret    

c0104a51 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104a51:	55                   	push   %ebp
c0104a52:	89 e5                	mov    %esp,%ebp
c0104a54:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104a57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a5e:	00 
c0104a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a69:	89 04 24             	mov    %eax,(%esp)
c0104a6c:	e8 87 fd ff ff       	call   c01047f8 <get_pte>
c0104a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a78:	74 19                	je     c0104a93 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104a81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a8b:	89 04 24             	mov    %eax,(%esp)
c0104a8e:	e8 30 ff ff ff       	call   c01049c3 <page_remove_pte>
    }
}
c0104a93:	c9                   	leave  
c0104a94:	c3                   	ret    

c0104a95 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104a95:	55                   	push   %ebp
c0104a96:	89 e5                	mov    %esp,%ebp
c0104a98:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104a9b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104aa2:	00 
c0104aa3:	8b 45 10             	mov    0x10(%ebp),%eax
c0104aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aad:	89 04 24             	mov    %eax,(%esp)
c0104ab0:	e8 43 fd ff ff       	call   c01047f8 <get_pte>
c0104ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104ab8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104abc:	75 0a                	jne    c0104ac8 <page_insert+0x33>
        return -E_NO_MEM;
c0104abe:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104ac3:	e9 84 00 00 00       	jmp    c0104b4c <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104acb:	89 04 24             	mov    %eax,(%esp)
c0104ace:	e8 e1 f3 ff ff       	call   c0103eb4 <page_ref_inc>
    if (*ptep & PTE_P) {
c0104ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ad6:	8b 00                	mov    (%eax),%eax
c0104ad8:	83 e0 01             	and    $0x1,%eax
c0104adb:	85 c0                	test   %eax,%eax
c0104add:	74 3e                	je     c0104b1d <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae2:	8b 00                	mov    (%eax),%eax
c0104ae4:	89 04 24             	mov    %eax,(%esp)
c0104ae7:	e8 73 f3 ff ff       	call   c0103e5f <pte2page>
c0104aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104af5:	75 0d                	jne    c0104b04 <page_insert+0x6f>
            page_ref_dec(page);
c0104af7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104afa:	89 04 24             	mov    %eax,(%esp)
c0104afd:	e8 c9 f3 ff ff       	call   c0103ecb <page_ref_dec>
c0104b02:	eb 19                	jmp    c0104b1d <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104b0b:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b15:	89 04 24             	mov    %eax,(%esp)
c0104b18:	e8 a6 fe ff ff       	call   c01049c3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b20:	89 04 24             	mov    %eax,(%esp)
c0104b23:	e8 88 f2 ff ff       	call   c0103db0 <page2pa>
c0104b28:	0b 45 14             	or     0x14(%ebp),%eax
c0104b2b:	83 c8 01             	or     $0x1,%eax
c0104b2e:	89 c2                	mov    %eax,%edx
c0104b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b33:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104b35:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b3f:	89 04 24             	mov    %eax,(%esp)
c0104b42:	e8 07 00 00 00       	call   c0104b4e <tlb_invalidate>
    return 0;
c0104b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b4c:	c9                   	leave  
c0104b4d:	c3                   	ret    

c0104b4e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104b4e:	55                   	push   %ebp
c0104b4f:	89 e5                	mov    %esp,%ebp
c0104b51:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104b54:	0f 20 d8             	mov    %cr3,%eax
c0104b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0104b5d:	89 c2                	mov    %eax,%edx
c0104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b65:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104b6c:	77 23                	ja     c0104b91 <tlb_invalidate+0x43>
c0104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b71:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b75:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0104b7c:	c0 
c0104b7d:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104b84:	00 
c0104b85:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104b8c:	e8 cc bf ff ff       	call   c0100b5d <__panic>
c0104b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b94:	05 00 00 00 40       	add    $0x40000000,%eax
c0104b99:	39 c2                	cmp    %eax,%edx
c0104b9b:	75 0c                	jne    c0104ba9 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ba6:	0f 01 38             	invlpg (%eax)
    }
}
c0104ba9:	c9                   	leave  
c0104baa:	c3                   	ret    

c0104bab <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0104bab:	55                   	push   %ebp
c0104bac:	89 e5                	mov    %esp,%ebp
c0104bae:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0104bb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bb8:	e8 e5 f4 ff ff       	call   c01040a2 <alloc_pages>
c0104bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0104bc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bc4:	74 54                	je     c0104c1a <pgdir_alloc_page+0x6f>
        if (page_insert(pgdir, page, la, perm) ==-E_NO_MEM) {
c0104bc6:	8b 45 10             	mov    0x10(%ebp),%eax
c0104bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bd0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bde:	89 04 24             	mov    %eax,(%esp)
c0104be1:	e8 af fe ff ff       	call   c0104a95 <page_insert>
c0104be6:	83 f8 fc             	cmp    $0xfffffffc,%eax
c0104be9:	75 2f                	jne    c0104c1a <pgdir_alloc_page+0x6f>
            free_page(page);
c0104beb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bf2:	00 
c0104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf6:	89 04 24             	mov    %eax,(%esp)
c0104bf9:	e8 fe f4 ff ff       	call   c01040fc <free_pages>
			panic("pgdir_alloc_page:NO FREE PAGES1!!");
c0104bfe:	c7 44 24 08 94 7e 10 	movl   $0xc0107e94,0x8(%esp)
c0104c05:	c0 
c0104c06:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104c0d:	00 
c0104c0e:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104c15:	e8 43 bf ff ff       	call   c0100b5d <__panic>
        }
	}
    return page;
c0104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104c1d:	c9                   	leave  
c0104c1e:	c3                   	ret    

c0104c1f <check_alloc_page>:

static void
check_alloc_page(void) {
c0104c1f:	55                   	push   %ebp
c0104c20:	89 e5                	mov    %esp,%ebp
c0104c22:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104c25:	a1 c4 d9 11 c0       	mov    0xc011d9c4,%eax
c0104c2a:	8b 40 18             	mov    0x18(%eax),%eax
c0104c2d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104c2f:	c7 04 24 b8 7e 10 c0 	movl   $0xc0107eb8,(%esp)
c0104c36:	e8 8c b5 ff ff       	call   c01001c7 <cprintf>
}
c0104c3b:	c9                   	leave  
c0104c3c:	c3                   	ret    

c0104c3d <check_pgdir>:

static void
check_pgdir(void) {
c0104c3d:	55                   	push   %ebp
c0104c3e:	89 e5                	mov    %esp,%ebp
c0104c40:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104c43:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0104c48:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104c4d:	76 24                	jbe    c0104c73 <check_pgdir+0x36>
c0104c4f:	c7 44 24 0c d7 7e 10 	movl   $0xc0107ed7,0xc(%esp)
c0104c56:	c0 
c0104c57:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104c5e:	c0 
c0104c5f:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104c66:	00 
c0104c67:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104c6e:	e8 ea be ff ff       	call   c0100b5d <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104c73:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104c78:	85 c0                	test   %eax,%eax
c0104c7a:	74 0e                	je     c0104c8a <check_pgdir+0x4d>
c0104c7c:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104c81:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c86:	85 c0                	test   %eax,%eax
c0104c88:	74 24                	je     c0104cae <check_pgdir+0x71>
c0104c8a:	c7 44 24 0c f4 7e 10 	movl   $0xc0107ef4,0xc(%esp)
c0104c91:	c0 
c0104c92:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104c99:	c0 
c0104c9a:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104ca1:	00 
c0104ca2:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104ca9:	e8 af be ff ff       	call   c0100b5d <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104cae:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104cb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104cba:	00 
c0104cbb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cc2:	00 
c0104cc3:	89 04 24             	mov    %eax,(%esp)
c0104cc6:	e8 9f fc ff ff       	call   c010496a <get_page>
c0104ccb:	85 c0                	test   %eax,%eax
c0104ccd:	74 24                	je     c0104cf3 <check_pgdir+0xb6>
c0104ccf:	c7 44 24 0c 2c 7f 10 	movl   $0xc0107f2c,0xc(%esp)
c0104cd6:	c0 
c0104cd7:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104cde:	c0 
c0104cdf:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104ce6:	00 
c0104ce7:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104cee:	e8 6a be ff ff       	call   c0100b5d <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104cf3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cfa:	e8 a3 f3 ff ff       	call   c01040a2 <alloc_pages>
c0104cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104d02:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104d07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104d0e:	00 
c0104d0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d16:	00 
c0104d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104d1a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104d1e:	89 04 24             	mov    %eax,(%esp)
c0104d21:	e8 6f fd ff ff       	call   c0104a95 <page_insert>
c0104d26:	85 c0                	test   %eax,%eax
c0104d28:	74 24                	je     c0104d4e <check_pgdir+0x111>
c0104d2a:	c7 44 24 0c 54 7f 10 	movl   $0xc0107f54,0xc(%esp)
c0104d31:	c0 
c0104d32:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104d39:	c0 
c0104d3a:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104d41:	00 
c0104d42:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104d49:	e8 0f be ff ff       	call   c0100b5d <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104d4e:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104d53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d5a:	00 
c0104d5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d62:	00 
c0104d63:	89 04 24             	mov    %eax,(%esp)
c0104d66:	e8 8d fa ff ff       	call   c01047f8 <get_pte>
c0104d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d72:	75 24                	jne    c0104d98 <check_pgdir+0x15b>
c0104d74:	c7 44 24 0c 80 7f 10 	movl   $0xc0107f80,0xc(%esp)
c0104d7b:	c0 
c0104d7c:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104d83:	c0 
c0104d84:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0104d8b:	00 
c0104d8c:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104d93:	e8 c5 bd ff ff       	call   c0100b5d <__panic>
    assert(pa2page(*ptep) == p1);
c0104d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9b:	8b 00                	mov    (%eax),%eax
c0104d9d:	89 04 24             	mov    %eax,(%esp)
c0104da0:	e8 21 f0 ff ff       	call   c0103dc6 <pa2page>
c0104da5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104da8:	74 24                	je     c0104dce <check_pgdir+0x191>
c0104daa:	c7 44 24 0c ad 7f 10 	movl   $0xc0107fad,0xc(%esp)
c0104db1:	c0 
c0104db2:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104db9:	c0 
c0104dba:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104dc1:	00 
c0104dc2:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104dc9:	e8 8f bd ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p1) == 1);
c0104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd1:	89 04 24             	mov    %eax,(%esp)
c0104dd4:	e8 c4 f0 ff ff       	call   c0103e9d <page_ref>
c0104dd9:	83 f8 01             	cmp    $0x1,%eax
c0104ddc:	74 24                	je     c0104e02 <check_pgdir+0x1c5>
c0104dde:	c7 44 24 0c c2 7f 10 	movl   $0xc0107fc2,0xc(%esp)
c0104de5:	c0 
c0104de6:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104ded:	c0 
c0104dee:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104df5:	00 
c0104df6:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104dfd:	e8 5b bd ff ff       	call   c0100b5d <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104e02:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104e07:	8b 00                	mov    (%eax),%eax
c0104e09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e14:	c1 e8 0c             	shr    $0xc,%eax
c0104e17:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e1a:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c0104e1f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104e22:	72 23                	jb     c0104e47 <check_pgdir+0x20a>
c0104e24:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e27:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e2b:	c7 44 24 08 30 7d 10 	movl   $0xc0107d30,0x8(%esp)
c0104e32:	c0 
c0104e33:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104e3a:	00 
c0104e3b:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104e42:	e8 16 bd ff ff       	call   c0100b5d <__panic>
c0104e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e4a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104e4f:	83 c0 04             	add    $0x4,%eax
c0104e52:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104e55:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104e5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e61:	00 
c0104e62:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104e69:	00 
c0104e6a:	89 04 24             	mov    %eax,(%esp)
c0104e6d:	e8 86 f9 ff ff       	call   c01047f8 <get_pte>
c0104e72:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104e75:	74 24                	je     c0104e9b <check_pgdir+0x25e>
c0104e77:	c7 44 24 0c d4 7f 10 	movl   $0xc0107fd4,0xc(%esp)
c0104e7e:	c0 
c0104e7f:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104e86:	c0 
c0104e87:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104e8e:	00 
c0104e8f:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104e96:	e8 c2 bc ff ff       	call   c0100b5d <__panic>

    p2 = alloc_page();
c0104e9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ea2:	e8 fb f1 ff ff       	call   c01040a2 <alloc_pages>
c0104ea7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104eaa:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104eaf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104eb6:	00 
c0104eb7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ebe:	00 
c0104ebf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ec6:	89 04 24             	mov    %eax,(%esp)
c0104ec9:	e8 c7 fb ff ff       	call   c0104a95 <page_insert>
c0104ece:	85 c0                	test   %eax,%eax
c0104ed0:	74 24                	je     c0104ef6 <check_pgdir+0x2b9>
c0104ed2:	c7 44 24 0c fc 7f 10 	movl   $0xc0107ffc,0xc(%esp)
c0104ed9:	c0 
c0104eda:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104ee1:	c0 
c0104ee2:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104ee9:	00 
c0104eea:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104ef1:	e8 67 bc ff ff       	call   c0100b5d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104ef6:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104efb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f02:	00 
c0104f03:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104f0a:	00 
c0104f0b:	89 04 24             	mov    %eax,(%esp)
c0104f0e:	e8 e5 f8 ff ff       	call   c01047f8 <get_pte>
c0104f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f1a:	75 24                	jne    c0104f40 <check_pgdir+0x303>
c0104f1c:	c7 44 24 0c 34 80 10 	movl   $0xc0108034,0xc(%esp)
c0104f23:	c0 
c0104f24:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104f2b:	c0 
c0104f2c:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104f33:	00 
c0104f34:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104f3b:	e8 1d bc ff ff       	call   c0100b5d <__panic>
    assert(*ptep & PTE_U);
c0104f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f43:	8b 00                	mov    (%eax),%eax
c0104f45:	83 e0 04             	and    $0x4,%eax
c0104f48:	85 c0                	test   %eax,%eax
c0104f4a:	75 24                	jne    c0104f70 <check_pgdir+0x333>
c0104f4c:	c7 44 24 0c 64 80 10 	movl   $0xc0108064,0xc(%esp)
c0104f53:	c0 
c0104f54:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104f5b:	c0 
c0104f5c:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104f63:	00 
c0104f64:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104f6b:	e8 ed bb ff ff       	call   c0100b5d <__panic>
    assert(*ptep & PTE_W);
c0104f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f73:	8b 00                	mov    (%eax),%eax
c0104f75:	83 e0 02             	and    $0x2,%eax
c0104f78:	85 c0                	test   %eax,%eax
c0104f7a:	75 24                	jne    c0104fa0 <check_pgdir+0x363>
c0104f7c:	c7 44 24 0c 72 80 10 	movl   $0xc0108072,0xc(%esp)
c0104f83:	c0 
c0104f84:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104f8b:	c0 
c0104f8c:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104f93:	00 
c0104f94:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104f9b:	e8 bd bb ff ff       	call   c0100b5d <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104fa0:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0104fa5:	8b 00                	mov    (%eax),%eax
c0104fa7:	83 e0 04             	and    $0x4,%eax
c0104faa:	85 c0                	test   %eax,%eax
c0104fac:	75 24                	jne    c0104fd2 <check_pgdir+0x395>
c0104fae:	c7 44 24 0c 80 80 10 	movl   $0xc0108080,0xc(%esp)
c0104fb5:	c0 
c0104fb6:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104fbd:	c0 
c0104fbe:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0104fc5:	00 
c0104fc6:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0104fcd:	e8 8b bb ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p2) == 1);
c0104fd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fd5:	89 04 24             	mov    %eax,(%esp)
c0104fd8:	e8 c0 ee ff ff       	call   c0103e9d <page_ref>
c0104fdd:	83 f8 01             	cmp    $0x1,%eax
c0104fe0:	74 24                	je     c0105006 <check_pgdir+0x3c9>
c0104fe2:	c7 44 24 0c 96 80 10 	movl   $0xc0108096,0xc(%esp)
c0104fe9:	c0 
c0104fea:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0104ff1:	c0 
c0104ff2:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0104ff9:	00 
c0104ffa:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105001:	e8 57 bb ff ff       	call   c0100b5d <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105006:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c010500b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105012:	00 
c0105013:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010501a:	00 
c010501b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010501e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105022:	89 04 24             	mov    %eax,(%esp)
c0105025:	e8 6b fa ff ff       	call   c0104a95 <page_insert>
c010502a:	85 c0                	test   %eax,%eax
c010502c:	74 24                	je     c0105052 <check_pgdir+0x415>
c010502e:	c7 44 24 0c a8 80 10 	movl   $0xc01080a8,0xc(%esp)
c0105035:	c0 
c0105036:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c010503d:	c0 
c010503e:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105045:	00 
c0105046:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c010504d:	e8 0b bb ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p1) == 2);
c0105052:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105055:	89 04 24             	mov    %eax,(%esp)
c0105058:	e8 40 ee ff ff       	call   c0103e9d <page_ref>
c010505d:	83 f8 02             	cmp    $0x2,%eax
c0105060:	74 24                	je     c0105086 <check_pgdir+0x449>
c0105062:	c7 44 24 0c d4 80 10 	movl   $0xc01080d4,0xc(%esp)
c0105069:	c0 
c010506a:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105071:	c0 
c0105072:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105079:	00 
c010507a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105081:	e8 d7 ba ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p2) == 0);
c0105086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105089:	89 04 24             	mov    %eax,(%esp)
c010508c:	e8 0c ee ff ff       	call   c0103e9d <page_ref>
c0105091:	85 c0                	test   %eax,%eax
c0105093:	74 24                	je     c01050b9 <check_pgdir+0x47c>
c0105095:	c7 44 24 0c e6 80 10 	movl   $0xc01080e6,0xc(%esp)
c010509c:	c0 
c010509d:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01050a4:	c0 
c01050a5:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c01050ac:	00 
c01050ad:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01050b4:	e8 a4 ba ff ff       	call   c0100b5d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01050b9:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01050be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050c5:	00 
c01050c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01050cd:	00 
c01050ce:	89 04 24             	mov    %eax,(%esp)
c01050d1:	e8 22 f7 ff ff       	call   c01047f8 <get_pte>
c01050d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01050dd:	75 24                	jne    c0105103 <check_pgdir+0x4c6>
c01050df:	c7 44 24 0c 34 80 10 	movl   $0xc0108034,0xc(%esp)
c01050e6:	c0 
c01050e7:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01050ee:	c0 
c01050ef:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c01050f6:	00 
c01050f7:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01050fe:	e8 5a ba ff ff       	call   c0100b5d <__panic>
    assert(pa2page(*ptep) == p1);
c0105103:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105106:	8b 00                	mov    (%eax),%eax
c0105108:	89 04 24             	mov    %eax,(%esp)
c010510b:	e8 b6 ec ff ff       	call   c0103dc6 <pa2page>
c0105110:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105113:	74 24                	je     c0105139 <check_pgdir+0x4fc>
c0105115:	c7 44 24 0c ad 7f 10 	movl   $0xc0107fad,0xc(%esp)
c010511c:	c0 
c010511d:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105124:	c0 
c0105125:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c010512c:	00 
c010512d:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105134:	e8 24 ba ff ff       	call   c0100b5d <__panic>
    assert((*ptep & PTE_U) == 0);
c0105139:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010513c:	8b 00                	mov    (%eax),%eax
c010513e:	83 e0 04             	and    $0x4,%eax
c0105141:	85 c0                	test   %eax,%eax
c0105143:	74 24                	je     c0105169 <check_pgdir+0x52c>
c0105145:	c7 44 24 0c f8 80 10 	movl   $0xc01080f8,0xc(%esp)
c010514c:	c0 
c010514d:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105154:	c0 
c0105155:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c010515c:	00 
c010515d:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105164:	e8 f4 b9 ff ff       	call   c0100b5d <__panic>

    page_remove(boot_pgdir, 0x0);
c0105169:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c010516e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105175:	00 
c0105176:	89 04 24             	mov    %eax,(%esp)
c0105179:	e8 d3 f8 ff ff       	call   c0104a51 <page_remove>
    assert(page_ref(p1) == 1);
c010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105181:	89 04 24             	mov    %eax,(%esp)
c0105184:	e8 14 ed ff ff       	call   c0103e9d <page_ref>
c0105189:	83 f8 01             	cmp    $0x1,%eax
c010518c:	74 24                	je     c01051b2 <check_pgdir+0x575>
c010518e:	c7 44 24 0c c2 7f 10 	movl   $0xc0107fc2,0xc(%esp)
c0105195:	c0 
c0105196:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c010519d:	c0 
c010519e:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c01051a5:	00 
c01051a6:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01051ad:	e8 ab b9 ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p2) == 0);
c01051b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051b5:	89 04 24             	mov    %eax,(%esp)
c01051b8:	e8 e0 ec ff ff       	call   c0103e9d <page_ref>
c01051bd:	85 c0                	test   %eax,%eax
c01051bf:	74 24                	je     c01051e5 <check_pgdir+0x5a8>
c01051c1:	c7 44 24 0c e6 80 10 	movl   $0xc01080e6,0xc(%esp)
c01051c8:	c0 
c01051c9:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01051d0:	c0 
c01051d1:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c01051d8:	00 
c01051d9:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01051e0:	e8 78 b9 ff ff       	call   c0100b5d <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01051e5:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01051ea:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01051f1:	00 
c01051f2:	89 04 24             	mov    %eax,(%esp)
c01051f5:	e8 57 f8 ff ff       	call   c0104a51 <page_remove>
    assert(page_ref(p1) == 0);
c01051fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051fd:	89 04 24             	mov    %eax,(%esp)
c0105200:	e8 98 ec ff ff       	call   c0103e9d <page_ref>
c0105205:	85 c0                	test   %eax,%eax
c0105207:	74 24                	je     c010522d <check_pgdir+0x5f0>
c0105209:	c7 44 24 0c 0d 81 10 	movl   $0xc010810d,0xc(%esp)
c0105210:	c0 
c0105211:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105218:	c0 
c0105219:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0105220:	00 
c0105221:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105228:	e8 30 b9 ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p2) == 0);
c010522d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105230:	89 04 24             	mov    %eax,(%esp)
c0105233:	e8 65 ec ff ff       	call   c0103e9d <page_ref>
c0105238:	85 c0                	test   %eax,%eax
c010523a:	74 24                	je     c0105260 <check_pgdir+0x623>
c010523c:	c7 44 24 0c e6 80 10 	movl   $0xc01080e6,0xc(%esp)
c0105243:	c0 
c0105244:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c010524b:	c0 
c010524c:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0105253:	00 
c0105254:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c010525b:	e8 fd b8 ff ff       	call   c0100b5d <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
c0105260:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0105265:	8b 00                	mov    (%eax),%eax
c0105267:	89 04 24             	mov    %eax,(%esp)
c010526a:	e8 57 eb ff ff       	call   c0103dc6 <pa2page>
c010526f:	89 04 24             	mov    %eax,(%esp)
c0105272:	e8 26 ec ff ff       	call   c0103e9d <page_ref>
c0105277:	83 f8 01             	cmp    $0x1,%eax
c010527a:	74 24                	je     c01052a0 <check_pgdir+0x663>
c010527c:	c7 44 24 0c 20 81 10 	movl   $0xc0108120,0xc(%esp)
c0105283:	c0 
c0105284:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c010528b:	c0 
c010528c:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0105293:	00 
c0105294:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c010529b:	e8 bd b8 ff ff       	call   c0100b5d <__panic>
    free_page(pa2page(boot_pgdir[0]));
c01052a0:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01052a5:	8b 00                	mov    (%eax),%eax
c01052a7:	89 04 24             	mov    %eax,(%esp)
c01052aa:	e8 17 eb ff ff       	call   c0103dc6 <pa2page>
c01052af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052b6:	00 
c01052b7:	89 04 24             	mov    %eax,(%esp)
c01052ba:	e8 3d ee ff ff       	call   c01040fc <free_pages>
    boot_pgdir[0] = 0;
c01052bf:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01052c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01052ca:	c7 04 24 46 81 10 c0 	movl   $0xc0108146,(%esp)
c01052d1:	e8 f1 ae ff ff       	call   c01001c7 <cprintf>
}
c01052d6:	c9                   	leave  
c01052d7:	c3                   	ret    

c01052d8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01052d8:	55                   	push   %ebp
c01052d9:	89 e5                	mov    %esp,%ebp
c01052db:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01052de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01052e5:	e9 ca 00 00 00       	jmp    c01053b4 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01052ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052f3:	c1 e8 0c             	shr    $0xc,%eax
c01052f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01052f9:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c01052fe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105301:	72 23                	jb     c0105326 <check_boot_pgdir+0x4e>
c0105303:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105306:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010530a:	c7 44 24 08 30 7d 10 	movl   $0xc0107d30,0x8(%esp)
c0105311:	c0 
c0105312:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105319:	00 
c010531a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105321:	e8 37 b8 ff ff       	call   c0100b5d <__panic>
c0105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105329:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010532e:	89 c2                	mov    %eax,%edx
c0105330:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0105335:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010533c:	00 
c010533d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105341:	89 04 24             	mov    %eax,(%esp)
c0105344:	e8 af f4 ff ff       	call   c01047f8 <get_pte>
c0105349:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010534c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105350:	75 24                	jne    c0105376 <check_boot_pgdir+0x9e>
c0105352:	c7 44 24 0c 60 81 10 	movl   $0xc0108160,0xc(%esp)
c0105359:	c0 
c010535a:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105361:	c0 
c0105362:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105369:	00 
c010536a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105371:	e8 e7 b7 ff ff       	call   c0100b5d <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105376:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105379:	8b 00                	mov    (%eax),%eax
c010537b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105380:	89 c2                	mov    %eax,%edx
c0105382:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105385:	39 c2                	cmp    %eax,%edx
c0105387:	74 24                	je     c01053ad <check_boot_pgdir+0xd5>
c0105389:	c7 44 24 0c 9d 81 10 	movl   $0xc010819d,0xc(%esp)
c0105390:	c0 
c0105391:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105398:	c0 
c0105399:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01053a0:	00 
c01053a1:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01053a8:	e8 b0 b7 ff ff       	call   c0100b5d <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01053ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01053b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053b7:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c01053bc:	39 c2                	cmp    %eax,%edx
c01053be:	0f 82 26 ff ff ff    	jb     c01052ea <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01053c4:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01053c9:	05 ac 0f 00 00       	add    $0xfac,%eax
c01053ce:	8b 00                	mov    (%eax),%eax
c01053d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01053d5:	89 c2                	mov    %eax,%edx
c01053d7:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01053dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01053df:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01053e6:	77 23                	ja     c010540b <check_boot_pgdir+0x133>
c01053e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053ef:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c01053f6:	c0 
c01053f7:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c01053fe:	00 
c01053ff:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105406:	e8 52 b7 ff ff       	call   c0100b5d <__panic>
c010540b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010540e:	05 00 00 00 40       	add    $0x40000000,%eax
c0105413:	39 c2                	cmp    %eax,%edx
c0105415:	74 24                	je     c010543b <check_boot_pgdir+0x163>
c0105417:	c7 44 24 0c b4 81 10 	movl   $0xc01081b4,0xc(%esp)
c010541e:	c0 
c010541f:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105426:	c0 
c0105427:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010542e:	00 
c010542f:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105436:	e8 22 b7 ff ff       	call   c0100b5d <__panic>

    assert(boot_pgdir[0] == 0);
c010543b:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0105440:	8b 00                	mov    (%eax),%eax
c0105442:	85 c0                	test   %eax,%eax
c0105444:	74 24                	je     c010546a <check_boot_pgdir+0x192>
c0105446:	c7 44 24 0c e8 81 10 	movl   $0xc01081e8,0xc(%esp)
c010544d:	c0 
c010544e:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105455:	c0 
c0105456:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c010545d:	00 
c010545e:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105465:	e8 f3 b6 ff ff       	call   c0100b5d <__panic>

    struct Page *p;
    p = alloc_page();
c010546a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105471:	e8 2c ec ff ff       	call   c01040a2 <alloc_pages>
c0105476:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105479:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c010547e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105485:	00 
c0105486:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010548d:	00 
c010548e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105491:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105495:	89 04 24             	mov    %eax,(%esp)
c0105498:	e8 f8 f5 ff ff       	call   c0104a95 <page_insert>
c010549d:	85 c0                	test   %eax,%eax
c010549f:	74 24                	je     c01054c5 <check_boot_pgdir+0x1ed>
c01054a1:	c7 44 24 0c fc 81 10 	movl   $0xc01081fc,0xc(%esp)
c01054a8:	c0 
c01054a9:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01054b0:	c0 
c01054b1:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c01054b8:	00 
c01054b9:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01054c0:	e8 98 b6 ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p) == 1);
c01054c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054c8:	89 04 24             	mov    %eax,(%esp)
c01054cb:	e8 cd e9 ff ff       	call   c0103e9d <page_ref>
c01054d0:	83 f8 01             	cmp    $0x1,%eax
c01054d3:	74 24                	je     c01054f9 <check_boot_pgdir+0x221>
c01054d5:	c7 44 24 0c 2a 82 10 	movl   $0xc010822a,0xc(%esp)
c01054dc:	c0 
c01054dd:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01054e4:	c0 
c01054e5:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c01054ec:	00 
c01054ed:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01054f4:	e8 64 b6 ff ff       	call   c0100b5d <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01054f9:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c01054fe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105505:	00 
c0105506:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010550d:	00 
c010550e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105511:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105515:	89 04 24             	mov    %eax,(%esp)
c0105518:	e8 78 f5 ff ff       	call   c0104a95 <page_insert>
c010551d:	85 c0                	test   %eax,%eax
c010551f:	74 24                	je     c0105545 <check_boot_pgdir+0x26d>
c0105521:	c7 44 24 0c 3c 82 10 	movl   $0xc010823c,0xc(%esp)
c0105528:	c0 
c0105529:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105530:	c0 
c0105531:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c0105538:	00 
c0105539:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105540:	e8 18 b6 ff ff       	call   c0100b5d <__panic>
    assert(page_ref(p) == 2);
c0105545:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105548:	89 04 24             	mov    %eax,(%esp)
c010554b:	e8 4d e9 ff ff       	call   c0103e9d <page_ref>
c0105550:	83 f8 02             	cmp    $0x2,%eax
c0105553:	74 24                	je     c0105579 <check_boot_pgdir+0x2a1>
c0105555:	c7 44 24 0c 73 82 10 	movl   $0xc0108273,0xc(%esp)
c010555c:	c0 
c010555d:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105564:	c0 
c0105565:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c010556c:	00 
c010556d:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105574:	e8 e4 b5 ff ff       	call   c0100b5d <__panic>

    const char *str = "ucore: Hello world!!";
c0105579:	c7 45 dc 84 82 10 c0 	movl   $0xc0108284,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105580:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105583:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105587:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010558e:	e8 bf 18 00 00       	call   c0106e52 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105593:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010559a:	00 
c010559b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01055a2:	e8 24 19 00 00       	call   c0106ecb <strcmp>
c01055a7:	85 c0                	test   %eax,%eax
c01055a9:	74 24                	je     c01055cf <check_boot_pgdir+0x2f7>
c01055ab:	c7 44 24 0c 9c 82 10 	movl   $0xc010829c,0xc(%esp)
c01055b2:	c0 
c01055b3:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c01055ba:	c0 
c01055bb:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c01055c2:	00 
c01055c3:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c01055ca:	e8 8e b5 ff ff       	call   c0100b5d <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01055cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055d2:	89 04 24             	mov    %eax,(%esp)
c01055d5:	e8 31 e8 ff ff       	call   c0103e0b <page2kva>
c01055da:	05 00 01 00 00       	add    $0x100,%eax
c01055df:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01055e2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01055e9:	e8 0c 18 00 00       	call   c0106dfa <strlen>
c01055ee:	85 c0                	test   %eax,%eax
c01055f0:	74 24                	je     c0105616 <check_boot_pgdir+0x33e>
c01055f2:	c7 44 24 0c d4 82 10 	movl   $0xc01082d4,0xc(%esp)
c01055f9:	c0 
c01055fa:	c7 44 24 08 3b 7e 10 	movl   $0xc0107e3b,0x8(%esp)
c0105601:	c0 
c0105602:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0105609:	00 
c010560a:	c7 04 24 b7 7d 10 c0 	movl   $0xc0107db7,(%esp)
c0105611:	e8 47 b5 ff ff       	call   c0100b5d <__panic>

    free_page(p);
c0105616:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010561d:	00 
c010561e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105621:	89 04 24             	mov    %eax,(%esp)
c0105624:	e8 d3 ea ff ff       	call   c01040fc <free_pages>
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
c0105629:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c010562e:	8b 00                	mov    (%eax),%eax
c0105630:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105635:	89 04 24             	mov    %eax,(%esp)
c0105638:	e8 89 e7 ff ff       	call   c0103dc6 <pa2page>
c010563d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105644:	00 
c0105645:	89 04 24             	mov    %eax,(%esp)
c0105648:	e8 af ea ff ff       	call   c01040fc <free_pages>
    boot_pgdir[0] = 0;
c010564d:	a1 04 d9 11 c0       	mov    0xc011d904,%eax
c0105652:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105658:	c7 04 24 f8 82 10 c0 	movl   $0xc01082f8,(%esp)
c010565f:	e8 63 ab ff ff       	call   c01001c7 <cprintf>
}
c0105664:	c9                   	leave  
c0105665:	c3                   	ret    

c0105666 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105666:	55                   	push   %ebp
c0105667:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105669:	8b 45 08             	mov    0x8(%ebp),%eax
c010566c:	83 e0 04             	and    $0x4,%eax
c010566f:	85 c0                	test   %eax,%eax
c0105671:	74 07                	je     c010567a <perm2str+0x14>
c0105673:	b8 75 00 00 00       	mov    $0x75,%eax
c0105678:	eb 05                	jmp    c010567f <perm2str+0x19>
c010567a:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010567f:	a2 88 d9 11 c0       	mov    %al,0xc011d988
    str[1] = 'r';
c0105684:	c6 05 89 d9 11 c0 72 	movb   $0x72,0xc011d989
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010568b:	8b 45 08             	mov    0x8(%ebp),%eax
c010568e:	83 e0 02             	and    $0x2,%eax
c0105691:	85 c0                	test   %eax,%eax
c0105693:	74 07                	je     c010569c <perm2str+0x36>
c0105695:	b8 77 00 00 00       	mov    $0x77,%eax
c010569a:	eb 05                	jmp    c01056a1 <perm2str+0x3b>
c010569c:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01056a1:	a2 8a d9 11 c0       	mov    %al,0xc011d98a
    str[3] = '\0';
c01056a6:	c6 05 8b d9 11 c0 00 	movb   $0x0,0xc011d98b
    return str;
c01056ad:	b8 88 d9 11 c0       	mov    $0xc011d988,%eax
}
c01056b2:	5d                   	pop    %ebp
c01056b3:	c3                   	ret    

c01056b4 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01056b4:	55                   	push   %ebp
c01056b5:	89 e5                	mov    %esp,%ebp
c01056b7:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01056ba:	8b 45 10             	mov    0x10(%ebp),%eax
c01056bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056c0:	72 0a                	jb     c01056cc <get_pgtable_items+0x18>
        return 0;
c01056c2:	b8 00 00 00 00       	mov    $0x0,%eax
c01056c7:	e9 9c 00 00 00       	jmp    c0105768 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01056cc:	eb 04                	jmp    c01056d2 <get_pgtable_items+0x1e>
        start ++;
c01056ce:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01056d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01056d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056d8:	73 18                	jae    c01056f2 <get_pgtable_items+0x3e>
c01056da:	8b 45 10             	mov    0x10(%ebp),%eax
c01056dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01056e4:	8b 45 14             	mov    0x14(%ebp),%eax
c01056e7:	01 d0                	add    %edx,%eax
c01056e9:	8b 00                	mov    (%eax),%eax
c01056eb:	83 e0 01             	and    $0x1,%eax
c01056ee:	85 c0                	test   %eax,%eax
c01056f0:	74 dc                	je     c01056ce <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c01056f2:	8b 45 10             	mov    0x10(%ebp),%eax
c01056f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056f8:	73 69                	jae    c0105763 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01056fa:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01056fe:	74 08                	je     c0105708 <get_pgtable_items+0x54>
            *left_store = start;
c0105700:	8b 45 18             	mov    0x18(%ebp),%eax
c0105703:	8b 55 10             	mov    0x10(%ebp),%edx
c0105706:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105708:	8b 45 10             	mov    0x10(%ebp),%eax
c010570b:	8d 50 01             	lea    0x1(%eax),%edx
c010570e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105711:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105718:	8b 45 14             	mov    0x14(%ebp),%eax
c010571b:	01 d0                	add    %edx,%eax
c010571d:	8b 00                	mov    (%eax),%eax
c010571f:	83 e0 07             	and    $0x7,%eax
c0105722:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105725:	eb 04                	jmp    c010572b <get_pgtable_items+0x77>
            start ++;
c0105727:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c010572b:	8b 45 10             	mov    0x10(%ebp),%eax
c010572e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105731:	73 1d                	jae    c0105750 <get_pgtable_items+0x9c>
c0105733:	8b 45 10             	mov    0x10(%ebp),%eax
c0105736:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010573d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105740:	01 d0                	add    %edx,%eax
c0105742:	8b 00                	mov    (%eax),%eax
c0105744:	83 e0 07             	and    $0x7,%eax
c0105747:	89 c2                	mov    %eax,%edx
c0105749:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010574c:	39 c2                	cmp    %eax,%edx
c010574e:	74 d7                	je     c0105727 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105750:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105754:	74 08                	je     c010575e <get_pgtable_items+0xaa>
            *right_store = start;
c0105756:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105759:	8b 55 10             	mov    0x10(%ebp),%edx
c010575c:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010575e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105761:	eb 05                	jmp    c0105768 <get_pgtable_items+0xb4>
    }
    return 0;
c0105763:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105768:	c9                   	leave  
c0105769:	c3                   	ret    

c010576a <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010576a:	55                   	push   %ebp
c010576b:	89 e5                	mov    %esp,%ebp
c010576d:	57                   	push   %edi
c010576e:	56                   	push   %esi
c010576f:	53                   	push   %ebx
c0105770:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105773:	c7 04 24 18 83 10 c0 	movl   $0xc0108318,(%esp)
c010577a:	e8 48 aa ff ff       	call   c01001c7 <cprintf>
    size_t left, right = 0, perm;
c010577f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105786:	e9 fa 00 00 00       	jmp    c0105885 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010578b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010578e:	89 04 24             	mov    %eax,(%esp)
c0105791:	e8 d0 fe ff ff       	call   c0105666 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105796:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105799:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010579c:	29 d1                	sub    %edx,%ecx
c010579e:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01057a0:	89 d6                	mov    %edx,%esi
c01057a2:	c1 e6 16             	shl    $0x16,%esi
c01057a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01057a8:	89 d3                	mov    %edx,%ebx
c01057aa:	c1 e3 16             	shl    $0x16,%ebx
c01057ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01057b0:	89 d1                	mov    %edx,%ecx
c01057b2:	c1 e1 16             	shl    $0x16,%ecx
c01057b5:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01057b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01057bb:	29 d7                	sub    %edx,%edi
c01057bd:	89 fa                	mov    %edi,%edx
c01057bf:	89 44 24 14          	mov    %eax,0x14(%esp)
c01057c3:	89 74 24 10          	mov    %esi,0x10(%esp)
c01057c7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01057cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01057cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057d3:	c7 04 24 49 83 10 c0 	movl   $0xc0108349,(%esp)
c01057da:	e8 e8 a9 ff ff       	call   c01001c7 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01057df:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057e2:	c1 e0 0a             	shl    $0xa,%eax
c01057e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01057e8:	eb 54                	jmp    c010583e <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01057ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057ed:	89 04 24             	mov    %eax,(%esp)
c01057f0:	e8 71 fe ff ff       	call   c0105666 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01057f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01057f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01057fb:	29 d1                	sub    %edx,%ecx
c01057fd:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01057ff:	89 d6                	mov    %edx,%esi
c0105801:	c1 e6 0c             	shl    $0xc,%esi
c0105804:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105807:	89 d3                	mov    %edx,%ebx
c0105809:	c1 e3 0c             	shl    $0xc,%ebx
c010580c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010580f:	c1 e2 0c             	shl    $0xc,%edx
c0105812:	89 d1                	mov    %edx,%ecx
c0105814:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105817:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010581a:	29 d7                	sub    %edx,%edi
c010581c:	89 fa                	mov    %edi,%edx
c010581e:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105822:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105826:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010582a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010582e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105832:	c7 04 24 68 83 10 c0 	movl   $0xc0108368,(%esp)
c0105839:	e8 89 a9 ff ff       	call   c01001c7 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010583e:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105843:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105846:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105849:	89 ce                	mov    %ecx,%esi
c010584b:	c1 e6 0a             	shl    $0xa,%esi
c010584e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105851:	89 cb                	mov    %ecx,%ebx
c0105853:	c1 e3 0a             	shl    $0xa,%ebx
c0105856:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105859:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010585d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105860:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105864:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105868:	89 44 24 08          	mov    %eax,0x8(%esp)
c010586c:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105870:	89 1c 24             	mov    %ebx,(%esp)
c0105873:	e8 3c fe ff ff       	call   c01056b4 <get_pgtable_items>
c0105878:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010587b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010587f:	0f 85 65 ff ff ff    	jne    c01057ea <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105885:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c010588a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010588d:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105890:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105894:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105897:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010589b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010589f:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058a3:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01058aa:	00 
c01058ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01058b2:	e8 fd fd ff ff       	call   c01056b4 <get_pgtable_items>
c01058b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01058ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058be:	0f 85 c7 fe ff ff    	jne    c010578b <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01058c4:	c7 04 24 8c 83 10 c0 	movl   $0xc010838c,(%esp)
c01058cb:	e8 f7 a8 ff ff       	call   c01001c7 <cprintf>
}
c01058d0:	83 c4 4c             	add    $0x4c,%esp
c01058d3:	5b                   	pop    %ebx
c01058d4:	5e                   	pop    %esi
c01058d5:	5f                   	pop    %edi
c01058d6:	5d                   	pop    %ebp
c01058d7:	c3                   	ret    

c01058d8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01058d8:	52                   	push   %edx
    call *%ebx              # call fn
c01058d9:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01058db:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01058dc:	e8 10 08 00 00       	call   c01060f1 <do_exit>

c01058e1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01058e1:	55                   	push   %ebp
c01058e2:	89 e5                	mov    %esp,%ebp
c01058e4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01058e7:	9c                   	pushf  
c01058e8:	58                   	pop    %eax
c01058e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01058ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01058ef:	25 00 02 00 00       	and    $0x200,%eax
c01058f4:	85 c0                	test   %eax,%eax
c01058f6:	74 0c                	je     c0105904 <__intr_save+0x23>
        intr_disable();
c01058f8:	e8 43 bc ff ff       	call   c0101540 <intr_disable>
        return 1;
c01058fd:	b8 01 00 00 00       	mov    $0x1,%eax
c0105902:	eb 05                	jmp    c0105909 <__intr_save+0x28>
    }
    return 0;
c0105904:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105909:	c9                   	leave  
c010590a:	c3                   	ret    

c010590b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010590b:	55                   	push   %ebp
c010590c:	89 e5                	mov    %esp,%ebp
c010590e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0105911:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105915:	74 05                	je     c010591c <__intr_restore+0x11>
        intr_enable();
c0105917:	e8 1e bc ff ff       	call   c010153a <intr_enable>
    }
}
c010591c:	c9                   	leave  
c010591d:	c3                   	ret    

c010591e <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010591e:	55                   	push   %ebp
c010591f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105921:	8b 55 08             	mov    0x8(%ebp),%edx
c0105924:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0105929:	29 c2                	sub    %eax,%edx
c010592b:	89 d0                	mov    %edx,%eax
c010592d:	c1 f8 05             	sar    $0x5,%eax
}
c0105930:	5d                   	pop    %ebp
c0105931:	c3                   	ret    

c0105932 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105932:	55                   	push   %ebp
c0105933:	89 e5                	mov    %esp,%ebp
c0105935:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105938:	8b 45 08             	mov    0x8(%ebp),%eax
c010593b:	89 04 24             	mov    %eax,(%esp)
c010593e:	e8 db ff ff ff       	call   c010591e <page2ppn>
c0105943:	c1 e0 0c             	shl    $0xc,%eax
}
c0105946:	c9                   	leave  
c0105947:	c3                   	ret    

c0105948 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105948:	55                   	push   %ebp
c0105949:	89 e5                	mov    %esp,%ebp
c010594b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010594e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105951:	c1 e8 0c             	shr    $0xc,%eax
c0105954:	89 c2                	mov    %eax,%edx
c0105956:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c010595b:	39 c2                	cmp    %eax,%edx
c010595d:	72 1c                	jb     c010597b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010595f:	c7 44 24 08 c0 83 10 	movl   $0xc01083c0,0x8(%esp)
c0105966:	c0 
c0105967:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010596e:	00 
c010596f:	c7 04 24 df 83 10 c0 	movl   $0xc01083df,(%esp)
c0105976:	e8 e2 b1 ff ff       	call   c0100b5d <__panic>
    }
    return &pages[PPN(pa)];
c010597b:	a1 cc d9 11 c0       	mov    0xc011d9cc,%eax
c0105980:	8b 55 08             	mov    0x8(%ebp),%edx
c0105983:	c1 ea 0c             	shr    $0xc,%edx
c0105986:	c1 e2 05             	shl    $0x5,%edx
c0105989:	01 d0                	add    %edx,%eax
}
c010598b:	c9                   	leave  
c010598c:	c3                   	ret    

c010598d <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010598d:	55                   	push   %ebp
c010598e:	89 e5                	mov    %esp,%ebp
c0105990:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0105993:	8b 45 08             	mov    0x8(%ebp),%eax
c0105996:	89 04 24             	mov    %eax,(%esp)
c0105999:	e8 94 ff ff ff       	call   c0105932 <page2pa>
c010599e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a4:	c1 e8 0c             	shr    $0xc,%eax
c01059a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059aa:	a1 00 d9 11 c0       	mov    0xc011d900,%eax
c01059af:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01059b2:	72 23                	jb     c01059d7 <page2kva+0x4a>
c01059b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059bb:	c7 44 24 08 f0 83 10 	movl   $0xc01083f0,0x8(%esp)
c01059c2:	c0 
c01059c3:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01059ca:	00 
c01059cb:	c7 04 24 df 83 10 c0 	movl   $0xc01083df,(%esp)
c01059d2:	e8 86 b1 ff ff       	call   c0100b5d <__panic>
c01059d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059da:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01059df:	c9                   	leave  
c01059e0:	c3                   	ret    

c01059e1 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01059e1:	55                   	push   %ebp
c01059e2:	89 e5                	mov    %esp,%ebp
c01059e4:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01059e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059ed:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01059f4:	77 23                	ja     c0105a19 <kva2page+0x38>
c01059f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059fd:	c7 44 24 08 14 84 10 	movl   $0xc0108414,0x8(%esp)
c0105a04:	c0 
c0105a05:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0105a0c:	00 
c0105a0d:	c7 04 24 df 83 10 c0 	movl   $0xc01083df,(%esp)
c0105a14:	e8 44 b1 ff ff       	call   c0100b5d <__panic>
c0105a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a1c:	05 00 00 00 40       	add    $0x40000000,%eax
c0105a21:	89 04 24             	mov    %eax,(%esp)
c0105a24:	e8 1f ff ff ff       	call   c0105948 <pa2page>
}
c0105a29:	c9                   	leave  
c0105a2a:	c3                   	ret    

c0105a2b <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0105a2b:	55                   	push   %ebp
c0105a2c:	89 e5                	mov    %esp,%ebp
c0105a2e:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0105a31:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
c0105a38:	e8 08 e2 ff ff       	call   c0103c45 <kmalloc>
c0105a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0105a40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a44:	74 3a                	je     c0105a80 <alloc_proc+0x55>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        memset(proc, 0, sizeof(struct proc_struct));
c0105a46:	c7 44 24 08 60 00 00 	movl   $0x60,0x8(%esp)
c0105a4d:	00 
c0105a4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105a55:	00 
c0105a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a59:	89 04 24             	mov    %eax,(%esp)
c0105a5c:	e8 c8 16 00 00       	call   c0107129 <memset>
        proc->state = PROC_UNINIT;
c0105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a6d:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->cr3 = boot_cr3;
c0105a74:	8b 15 c8 d9 11 c0    	mov    0xc011d9c8,%edx
c0105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a7d:	89 50 3c             	mov    %edx,0x3c(%eax)
    }
    return proc;
c0105a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a83:	c9                   	leave  
c0105a84:	c3                   	ret    

c0105a85 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0105a85:	55                   	push   %ebp
c0105a86:	89 e5                	mov    %esp,%ebp
c0105a88:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0105a8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a8e:	83 c0 48             	add    $0x48,%eax
c0105a91:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0105a98:	00 
c0105a99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105aa0:	00 
c0105aa1:	89 04 24             	mov    %eax,(%esp)
c0105aa4:	e8 80 16 00 00       	call   c0107129 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0105aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aac:	8d 50 48             	lea    0x48(%eax),%edx
c0105aaf:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0105ab6:	00 
c0105ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105abe:	89 14 24             	mov    %edx,(%esp)
c0105ac1:	e8 45 17 00 00       	call   c010720b <memcpy>
}
c0105ac6:	c9                   	leave  
c0105ac7:	c3                   	ret    

c0105ac8 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0105ac8:	55                   	push   %ebp
c0105ac9:	89 e5                	mov    %esp,%ebp
c0105acb:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0105ace:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0105ad5:	00 
c0105ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105add:	00 
c0105ade:	c7 04 24 a4 d9 11 c0 	movl   $0xc011d9a4,(%esp)
c0105ae5:	e8 3f 16 00 00       	call   c0107129 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0105aea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aed:	83 c0 48             	add    $0x48,%eax
c0105af0:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0105af7:	00 
c0105af8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105afc:	c7 04 24 a4 d9 11 c0 	movl   $0xc011d9a4,(%esp)
c0105b03:	e8 03 17 00 00       	call   c010720b <memcpy>
}
c0105b08:	c9                   	leave  
c0105b09:	c3                   	ret    

c0105b0a <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0105b0a:	55                   	push   %ebp
c0105b0b:	89 e5                	mov    %esp,%ebp
c0105b0d:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0105b10:	c7 45 f8 d0 d9 11 c0 	movl   $0xc011d9d0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0105b17:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105b1c:	83 c0 01             	add    $0x1,%eax
c0105b1f:	a3 58 ca 11 c0       	mov    %eax,0xc011ca58
c0105b24:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105b29:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0105b2e:	7e 0c                	jle    c0105b3c <get_pid+0x32>
        last_pid = 1;
c0105b30:	c7 05 58 ca 11 c0 01 	movl   $0x1,0xc011ca58
c0105b37:	00 00 00 
        goto inside;
c0105b3a:	eb 13                	jmp    c0105b4f <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0105b3c:	8b 15 58 ca 11 c0    	mov    0xc011ca58,%edx
c0105b42:	a1 5c ca 11 c0       	mov    0xc011ca5c,%eax
c0105b47:	39 c2                	cmp    %eax,%edx
c0105b49:	0f 8c ac 00 00 00    	jl     c0105bfb <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0105b4f:	c7 05 5c ca 11 c0 00 	movl   $0x2000,0xc011ca5c
c0105b56:	20 00 00 
    repeat:
        le = list;
c0105b59:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105b5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0105b5f:	eb 7f                	jmp    c0105be0 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0105b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b64:	83 e8 58             	sub    $0x58,%eax
c0105b67:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0105b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b6d:	8b 50 04             	mov    0x4(%eax),%edx
c0105b70:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105b75:	39 c2                	cmp    %eax,%edx
c0105b77:	75 3e                	jne    c0105bb7 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0105b79:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105b7e:	83 c0 01             	add    $0x1,%eax
c0105b81:	a3 58 ca 11 c0       	mov    %eax,0xc011ca58
c0105b86:	8b 15 58 ca 11 c0    	mov    0xc011ca58,%edx
c0105b8c:	a1 5c ca 11 c0       	mov    0xc011ca5c,%eax
c0105b91:	39 c2                	cmp    %eax,%edx
c0105b93:	7c 4b                	jl     c0105be0 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0105b95:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105b9a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0105b9f:	7e 0a                	jle    c0105bab <get_pid+0xa1>
                        last_pid = 1;
c0105ba1:	c7 05 58 ca 11 c0 01 	movl   $0x1,0xc011ca58
c0105ba8:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0105bab:	c7 05 5c ca 11 c0 00 	movl   $0x2000,0xc011ca5c
c0105bb2:	20 00 00 
                    goto repeat;
c0105bb5:	eb a2                	jmp    c0105b59 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bba:	8b 50 04             	mov    0x4(%eax),%edx
c0105bbd:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
c0105bc2:	39 c2                	cmp    %eax,%edx
c0105bc4:	7e 1a                	jle    c0105be0 <get_pid+0xd6>
c0105bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bc9:	8b 50 04             	mov    0x4(%eax),%edx
c0105bcc:	a1 5c ca 11 c0       	mov    0xc011ca5c,%eax
c0105bd1:	39 c2                	cmp    %eax,%edx
c0105bd3:	7d 0b                	jge    c0105be0 <get_pid+0xd6>
                next_safe = proc->pid;
c0105bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bd8:	8b 40 04             	mov    0x4(%eax),%eax
c0105bdb:	a3 5c ca 11 c0       	mov    %eax,0xc011ca5c
c0105be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105be9:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0105bec:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0105bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105bf2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0105bf5:	0f 85 66 ff ff ff    	jne    c0105b61 <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0105bfb:	a1 58 ca 11 c0       	mov    0xc011ca58,%eax
}
c0105c00:	c9                   	leave  
c0105c01:	c3                   	ret    

c0105c02 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0105c02:	55                   	push   %ebp
c0105c03:	89 e5                	mov    %esp,%ebp
c0105c05:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0105c08:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0105c0d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105c10:	74 63                	je     c0105c75 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0105c12:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0105c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0105c20:	e8 bc fc ff ff       	call   c01058e1 <__intr_save>
c0105c25:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0105c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2b:	a3 9c d9 11 c0       	mov    %eax,0xc011d99c
            load_esp0(next->kstack + KSTACKSIZE);
c0105c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c33:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c36:	05 00 20 00 00       	add    $0x2000,%eax
c0105c3b:	89 04 24             	mov    %eax,(%esp)
c0105c3e:	e8 11 e3 ff ff       	call   c0103f54 <load_esp0>
            lcr3(next->cr3);
c0105c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c46:	8b 40 3c             	mov    0x3c(%eax),%eax
c0105c49:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0105c4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c4f:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0105c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c55:	8d 50 18             	lea    0x18(%eax),%edx
c0105c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c5b:	83 c0 18             	add    $0x18,%eax
c0105c5e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c62:	89 04 24             	mov    %eax,(%esp)
c0105c65:	e8 70 08 00 00       	call   c01064da <switch_to>
        }
        local_intr_restore(intr_flag);
c0105c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c6d:	89 04 24             	mov    %eax,(%esp)
c0105c70:	e8 96 fc ff ff       	call   c010590b <__intr_restore>
    }
}
c0105c75:	c9                   	leave  
c0105c76:	c3                   	ret    

c0105c77 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0105c77:	55                   	push   %ebp
c0105c78:	89 e5                	mov    %esp,%ebp
c0105c7a:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0105c7d:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0105c82:	8b 40 38             	mov    0x38(%eax),%eax
c0105c85:	89 04 24             	mov    %eax,(%esp)
c0105c88:	e8 ad c0 ff ff       	call   c0101d3a <forkrets>
}
c0105c8d:	c9                   	leave  
c0105c8e:	c3                   	ret    

c0105c8f <find_proc>:


// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0105c8f:	55                   	push   %ebp
c0105c90:	89 e5                	mov    %esp,%ebp
c0105c92:	83 ec 10             	sub    $0x10,%esp
    if (0 < pid && pid < MAX_PID) {
c0105c95:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c99:	7e 48                	jle    c0105ce3 <find_proc+0x54>
c0105c9b:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0105ca2:	7f 3f                	jg     c0105ce3 <find_proc+0x54>
        list_entry_t *list = &proc_list,  *le = list;
c0105ca4:	c7 45 f8 d0 d9 11 c0 	movl   $0xc011d9d0,-0x8(%ebp)
c0105cab:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105cae:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0105cb1:	eb 19                	jmp    c0105ccc <find_proc+0x3d>
            struct proc_struct *proc = le2proc(le, list_link);
c0105cb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105cb6:	83 e8 58             	sub    $0x58,%eax
c0105cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == pid) {
c0105cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cbf:	8b 40 04             	mov    0x4(%eax),%eax
c0105cc2:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105cc5:	75 05                	jne    c0105ccc <find_proc+0x3d>
                return proc;
c0105cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cca:	eb 1c                	jmp    c0105ce8 <find_proc+0x59>
c0105ccc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105ccf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cd5:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = &proc_list,  *le = list;
        while ((le = list_next(le)) != list) {
c0105cd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0105cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105cde:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0105ce1:	75 d0                	jne    c0105cb3 <find_proc+0x24>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0105ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ce8:	c9                   	leave  
c0105ce9:	c3                   	ret    

c0105cea <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0105cea:	55                   	push   %ebp
c0105ceb:	89 e5                	mov    %esp,%ebp
c0105ced:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0105cf0:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0105cf7:	00 
c0105cf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105cff:	00 
c0105d00:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0105d03:	89 04 24             	mov    %eax,(%esp)
c0105d06:	e8 1e 14 00 00       	call   c0107129 <memset>
    tf.tf_cs = KERNEL_CS;
c0105d0b:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0105d11:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0105d17:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0105d1b:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0105d1f:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0105d23:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0105d27:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0105d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d30:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0105d33:	b8 d8 58 10 c0       	mov    $0xc01058d8,%eax
c0105d38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0105d3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d3e:	80 cc 01             	or     $0x1,%ah
c0105d41:	89 c2                	mov    %eax,%edx
c0105d43:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0105d46:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105d51:	00 
c0105d52:	89 14 24             	mov    %edx,(%esp)
c0105d55:	e8 3c 01 00 00       	call   c0105e96 <do_fork>
}
c0105d5a:	c9                   	leave  
c0105d5b:	c3                   	ret    

c0105d5c <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0105d5c:	55                   	push   %ebp
c0105d5d:	89 e5                	mov    %esp,%ebp
c0105d5f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0105d62:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105d69:	e8 34 e3 ff ff       	call   c01040a2 <alloc_pages>
c0105d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105d71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d75:	74 1a                	je     c0105d91 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0105d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d7a:	89 04 24             	mov    %eax,(%esp)
c0105d7d:	e8 0b fc ff ff       	call   c010598d <page2kva>
c0105d82:	89 c2                	mov    %eax,%edx
c0105d84:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d87:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0105d8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d8f:	eb 05                	jmp    c0105d96 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0105d91:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0105d96:	c9                   	leave  
c0105d97:	c3                   	ret    

c0105d98 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0105d98:	55                   	push   %ebp
c0105d99:	89 e5                	mov    %esp,%ebp
c0105d9b:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0105d9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da1:	8b 40 0c             	mov    0xc(%eax),%eax
c0105da4:	89 04 24             	mov    %eax,(%esp)
c0105da7:	e8 35 fc ff ff       	call   c01059e1 <kva2page>
c0105dac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105db3:	00 
c0105db4:	89 04 24             	mov    %eax,(%esp)
c0105db7:	e8 40 e3 ff ff       	call   c01040fc <free_pages>
}
c0105dbc:	c9                   	leave  
c0105dbd:	c3                   	ret    

c0105dbe <copy_thread>:


// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0105dbe:	55                   	push   %ebp
c0105dbf:	89 e5                	mov    %esp,%ebp
c0105dc1:	57                   	push   %edi
c0105dc2:	56                   	push   %esi
c0105dc3:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0105dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc7:	8b 40 0c             	mov    0xc(%eax),%eax
c0105dca:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0105dcf:	89 c2                	mov    %eax,%edx
c0105dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd4:	89 50 38             	mov    %edx,0x38(%eax)
    *(proc->tf) = *tf;
c0105dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dda:	8b 40 38             	mov    0x38(%eax),%eax
c0105ddd:	8b 55 10             	mov    0x10(%ebp),%edx
c0105de0:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0105de5:	89 c1                	mov    %eax,%ecx
c0105de7:	83 e1 01             	and    $0x1,%ecx
c0105dea:	85 c9                	test   %ecx,%ecx
c0105dec:	74 0e                	je     c0105dfc <copy_thread+0x3e>
c0105dee:	0f b6 0a             	movzbl (%edx),%ecx
c0105df1:	88 08                	mov    %cl,(%eax)
c0105df3:	83 c0 01             	add    $0x1,%eax
c0105df6:	83 c2 01             	add    $0x1,%edx
c0105df9:	83 eb 01             	sub    $0x1,%ebx
c0105dfc:	89 c1                	mov    %eax,%ecx
c0105dfe:	83 e1 02             	and    $0x2,%ecx
c0105e01:	85 c9                	test   %ecx,%ecx
c0105e03:	74 0f                	je     c0105e14 <copy_thread+0x56>
c0105e05:	0f b7 0a             	movzwl (%edx),%ecx
c0105e08:	66 89 08             	mov    %cx,(%eax)
c0105e0b:	83 c0 02             	add    $0x2,%eax
c0105e0e:	83 c2 02             	add    $0x2,%edx
c0105e11:	83 eb 02             	sub    $0x2,%ebx
c0105e14:	89 d9                	mov    %ebx,%ecx
c0105e16:	c1 e9 02             	shr    $0x2,%ecx
c0105e19:	89 c7                	mov    %eax,%edi
c0105e1b:	89 d6                	mov    %edx,%esi
c0105e1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e1f:	89 f2                	mov    %esi,%edx
c0105e21:	89 f8                	mov    %edi,%eax
c0105e23:	b9 00 00 00 00       	mov    $0x0,%ecx
c0105e28:	89 de                	mov    %ebx,%esi
c0105e2a:	83 e6 02             	and    $0x2,%esi
c0105e2d:	85 f6                	test   %esi,%esi
c0105e2f:	74 0b                	je     c0105e3c <copy_thread+0x7e>
c0105e31:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0105e35:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0105e39:	83 c1 02             	add    $0x2,%ecx
c0105e3c:	83 e3 01             	and    $0x1,%ebx
c0105e3f:	85 db                	test   %ebx,%ebx
c0105e41:	74 07                	je     c0105e4a <copy_thread+0x8c>
c0105e43:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0105e47:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0105e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4d:	8b 40 38             	mov    0x38(%eax),%eax
c0105e50:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0105e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e5a:	8b 40 38             	mov    0x38(%eax),%eax
c0105e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e60:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0105e63:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e66:	8b 40 38             	mov    0x38(%eax),%eax
c0105e69:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e6c:	8b 52 38             	mov    0x38(%edx),%edx
c0105e6f:	8b 52 40             	mov    0x40(%edx),%edx
c0105e72:	80 ce 02             	or     $0x2,%dh
c0105e75:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0105e78:	ba 77 5c 10 c0       	mov    $0xc0105c77,%edx
c0105e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e80:	89 50 18             	mov    %edx,0x18(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0105e83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e86:	8b 40 38             	mov    0x38(%eax),%eax
c0105e89:	89 c2                	mov    %eax,%edx
c0105e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e8e:	89 50 1c             	mov    %edx,0x1c(%eax)
}
c0105e91:	5b                   	pop    %ebx
c0105e92:	5e                   	pop    %esi
c0105e93:	5f                   	pop    %edi
c0105e94:	5d                   	pop    %ebp
c0105e95:	c3                   	ret    

c0105e96 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0105e96:	55                   	push   %ebp
c0105e97:	89 e5                	mov    %esp,%ebp
c0105e99:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_NO_FREE_PROC;
c0105e9c:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0105ea3:	a1 a0 d9 11 c0       	mov    0xc011d9a0,%eax
c0105ea8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105ead:	7e 05                	jle    c0105eb4 <do_fork+0x1e>
        goto fork_out;
c0105eaf:	e9 c9 00 00 00       	jmp    c0105f7d <do_fork+0xe7>
    }
    ret = -E_NO_MEM;
c0105eb4:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc();
c0105ebb:	e8 6b fb ff ff       	call   c0105a2b <alloc_proc>
c0105ec0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    proc->pid = get_pid();
c0105ec3:	e8 42 fc ff ff       	call   c0105b0a <get_pid>
c0105ec8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ecb:	89 42 04             	mov    %eax,0x4(%edx)
    cprintf(" alloc_proc: proc pid %d will init\n", proc->pid);
c0105ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ed1:	8b 40 04             	mov    0x4(%eax),%eax
c0105ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ed8:	c7 04 24 38 84 10 c0 	movl   $0xc0108438,(%esp)
c0105edf:	e8 e3 a2 ff ff       	call   c01001c7 <cprintf>
    //    2. call setup_kstack to allocate a kernel stack for child process
    setup_kstack(proc);
c0105ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ee7:	89 04 24             	mov    %eax,(%esp)
c0105eea:	e8 6d fe ff ff       	call   c0105d5c <setup_kstack>
    //    3. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf);
c0105eef:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ef2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f00:	89 04 24             	mov    %eax,(%esp)
c0105f03:	e8 b6 fe ff ff       	call   c0105dbe <copy_thread>
    //    4. insert proc_struct into  proc_list
    list_add_before(&proc_list, &proc->list_link);
c0105f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f0b:	83 c0 58             	add    $0x58,%eax
c0105f0e:	c7 45 ec d0 d9 11 c0 	movl   $0xc011d9d0,-0x14(%ebp)
c0105f15:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0105f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f1b:	8b 00                	mov    (%eax),%eax
c0105f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105f20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105f26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f29:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105f2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105f32:	89 10                	mov    %edx,(%eax)
c0105f34:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f37:	8b 10                	mov    (%eax),%edx
c0105f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f3c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f42:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f45:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f4b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f4e:	89 10                	mov    %edx,(%eax)
    //    5. call wakup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
c0105f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f53:	89 04 24             	mov    %eax,(%esp)
c0105f56:	e8 f3 05 00 00       	call   c010654e <wakeup_proc>
    //    7. set ret vaule using child proc's pid
    nr_process++;
c0105f5b:	a1 a0 d9 11 c0       	mov    0xc011d9a0,%eax
c0105f60:	83 c0 01             	add    $0x1,%eax
c0105f63:	a3 a0 d9 11 c0       	mov    %eax,0xc011d9a0
    ret = proc->pid;
c0105f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f6b:	8b 40 04             	mov    0x4(%eax),%eax
c0105f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//  8. set parent
	proc->parent=current;
c0105f71:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c0105f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f7a:	89 50 14             	mov    %edx,0x14(%eax)
fork_out:
    return ret;
c0105f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
c0105f80:	c9                   	leave  
c0105f81:	c3                   	ret    

c0105f82 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0105f82:	55                   	push   %ebp
c0105f83:	89 e5                	mov    %esp,%ebp
c0105f85:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0105f88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8b:	83 c0 58             	add    $0x58,%eax
c0105f8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f94:	8b 40 04             	mov    0x4(%eax),%eax
c0105f97:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105f9a:	8b 12                	mov    (%edx),%edx
c0105f9c:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105fa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fa8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fae:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105fb1:	89 10                	mov    %edx,(%eax)
    nr_process --;
c0105fb3:	a1 a0 d9 11 c0       	mov    0xc011d9a0,%eax
c0105fb8:	83 e8 01             	sub    $0x1,%eax
c0105fbb:	a3 a0 d9 11 c0       	mov    %eax,0xc011d9a0
}
c0105fc0:	c9                   	leave  
c0105fc1:	c3                   	ret    

c0105fc2 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c0105fc2:	55                   	push   %ebp
c0105fc3:	89 e5                	mov    %esp,%ebp
c0105fc5:	83 ec 38             	sub    $0x38,%esp
    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
	cprintf("do_wait: begin\n");
c0105fc8:	c7 04 24 5c 84 10 c0 	movl   $0xc010845c,(%esp)
c0105fcf:	e8 f3 a1 ff ff       	call   c01001c7 <cprintf>
    haskid = 0;
c0105fd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	list_entry_t *list = &proc_list,  *le = list;
c0105fdb:	c7 45 ec d0 d9 11 c0 	movl   $0xc011d9d0,-0x14(%ebp)
c0105fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while ((le = list_next(le)) != list) {
c0105fe8:	eb 47                	jmp    c0106031 <do_wait+0x6f>
		proc = le2proc(le, list_link);
c0105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fed:	83 e8 58             	sub    $0x58,%eax
c0105ff0:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if (proc != NULL) {
c0105ff3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ff7:	74 38                	je     c0106031 <do_wait+0x6f>
			 haskid = 1;
c0105ff9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		    if (proc->state == PROC_ZOMBIE) {
c0106000:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106003:	8b 00                	mov    (%eax),%eax
c0106005:	83 f8 03             	cmp    $0x3,%eax
c0106008:	75 27                	jne    c0106031 <do_wait+0x6f>
			     goto found;
c010600a:	90                   	nop
        goto repeat;
    }
    return -E_BAD_PROC;

found:
	cprintf("do_wait: has kid find child  pid%d\n",proc->pid);
c010600b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010600e:	8b 40 04             	mov    0x4(%eax),%eax
c0106011:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106015:	c7 04 24 c4 84 10 c0 	movl   $0xc01084c4,(%esp)
c010601c:	e8 a6 a1 ff ff       	call   c01001c7 <cprintf>
    if (proc == idleproc ) {
c0106021:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c0106026:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106029:	0f 85 87 00 00 00    	jne    c01060b6 <do_wait+0xf4>
c010602f:	eb 69                	jmp    c010609a <do_wait+0xd8>
c0106031:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106034:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106037:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010603a:	8b 40 04             	mov    0x4(%eax),%eax
    bool intr_flag, haskid;
repeat:
	cprintf("do_wait: begin\n");
    haskid = 0;
	list_entry_t *list = &proc_list,  *le = list;
	while ((le = list_next(le)) != list) {
c010603d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106040:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106043:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106046:	75 a2                	jne    c0105fea <do_wait+0x28>
		    if (proc->state == PROC_ZOMBIE) {
			     goto found;
		   }
		}
	}
    if (haskid) {
c0106048:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010604c:	74 45                	je     c0106093 <do_wait+0xd1>
		cprintf("do_wait: has kid begin\n");
c010604e:	c7 04 24 6c 84 10 c0 	movl   $0xc010846c,(%esp)
c0106055:	e8 6d a1 ff ff       	call   c01001c7 <cprintf>
        cprintf("do_wait: proc pid %d will from PROC_ZOMBIE TO PROC_SLEEPING\n", current->pid);
c010605a:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c010605f:	8b 40 04             	mov    0x4(%eax),%eax
c0106062:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106066:	c7 04 24 84 84 10 c0 	movl   $0xc0108484,(%esp)
c010606d:	e8 55 a1 ff ff       	call   c01001c7 <cprintf>
        current->state = PROC_SLEEPING;
c0106072:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106077:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010607d:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106082:	c7 40 44 01 00 00 00 	movl   $0x1,0x44(%eax)
        schedule();
c0106089:	e8 1f 05 00 00       	call   c01065ad <schedule>
        goto repeat;
c010608e:	e9 35 ff ff ff       	jmp    c0105fc8 <do_wait+0x6>
    }
    return -E_BAD_PROC;
c0106093:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c0106098:	eb 55                	jmp    c01060ef <do_wait+0x12d>

found:
	cprintf("do_wait: has kid find child  pid%d\n",proc->pid);
    if (proc == idleproc ) {
        panic("wait idleproc \n");
c010609a:	c7 44 24 08 e8 84 10 	movl   $0xc01084e8,0x8(%esp)
c01060a1:	c0 
c01060a2:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c01060a9:	00 
c01060aa:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c01060b1:	e8 a7 aa ff ff       	call   c0100b5d <__panic>
    }

    local_intr_save(intr_flag);
c01060b6:	e8 26 f8 ff ff       	call   c01058e1 <__intr_save>
c01060bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    {
        remove_links(proc);
c01060be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060c1:	89 04 24             	mov    %eax,(%esp)
c01060c4:	e8 b9 fe ff ff       	call   c0105f82 <remove_links>
    }
    local_intr_restore(intr_flag);
c01060c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060cc:	89 04 24             	mov    %eax,(%esp)
c01060cf:	e8 37 f8 ff ff       	call   c010590b <__intr_restore>
    put_kstack(proc);
c01060d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060d7:	89 04 24             	mov    %eax,(%esp)
c01060da:	e8 b9 fc ff ff       	call   c0105d98 <put_kstack>
    kfree(proc);
c01060df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060e2:	89 04 24             	mov    %eax,(%esp)
c01060e5:	e8 76 db ff ff       	call   c0103c60 <kfree>
    return 0;
c01060ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01060ef:	c9                   	leave  
c01060f0:	c3                   	ret    

c01060f1 <do_exit>:

// do_exit - called by sys_exit
//   1. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   2. call scheduler to switch to other process
int
do_exit(int error_code) {
c01060f1:	55                   	push   %ebp
c01060f2:	89 e5                	mov    %esp,%ebp
c01060f4:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c01060f7:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c01060fd:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c0106102:	39 c2                	cmp    %eax,%edx
c0106104:	75 1c                	jne    c0106122 <do_exit+0x31>
        panic("idleproc exit.\n");
c0106106:	c7 44 24 08 0c 85 10 	movl   $0xc010850c,0x8(%esp)
c010610d:	c0 
c010610e:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0106115:	00 
c0106116:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c010611d:	e8 3b aa ff ff       	call   c0100b5d <__panic>
    }
	cprintf(" do_exit: proc pid %d will exit\n", current->pid);
c0106122:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106127:	8b 40 04             	mov    0x4(%eax),%eax
c010612a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010612e:	c7 04 24 1c 85 10 c0 	movl   $0xc010851c,(%esp)
c0106135:	e8 8d a0 ff ff       	call   c01001c7 <cprintf>
	cprintf(" do_exit: proc  parent %x\n", current->parent);
c010613a:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c010613f:	8b 40 14             	mov    0x14(%eax),%eax
c0106142:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106146:	c7 04 24 3d 85 10 c0 	movl   $0xc010853d,(%esp)
c010614d:	e8 75 a0 ff ff       	call   c01001c7 <cprintf>
    cprintf(" do_exit: proc pid %d will from PROC_RUNNABLE TO PROC_ZOMBIE\n", current->pid);
c0106152:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106157:	8b 40 04             	mov    0x4(%eax),%eax
c010615a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010615e:	c7 04 24 58 85 10 c0 	movl   $0xc0108558,(%esp)
c0106165:	e8 5d a0 ff ff       	call   c01001c7 <cprintf>
    current->state = PROC_ZOMBIE;
c010616a:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c010616f:	c7 00 03 00 00 00    	movl   $0x3,(%eax)

	bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c0106175:	e8 67 f7 ff ff       	call   c01058e1 <__intr_save>
c010617a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        proc = current->parent;
c010617d:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106182:	8b 40 14             	mov    0x14(%eax),%eax
c0106185:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (proc->wait_state == WT_CHILD) {
c0106188:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010618b:	8b 40 44             	mov    0x44(%eax),%eax
c010618e:	83 f8 01             	cmp    $0x1,%eax
c0106191:	75 0b                	jne    c010619e <do_exit+0xad>
            wakeup_proc(proc);
c0106193:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106196:	89 04 24             	mov    %eax,(%esp)
c0106199:	e8 b0 03 00 00       	call   c010654e <wakeup_proc>
        }
	}
    local_intr_restore(intr_flag);
c010619e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061a1:	89 04 24             	mov    %eax,(%esp)
c01061a4:	e8 62 f7 ff ff       	call   c010590b <__intr_restore>
	schedule();
c01061a9:	e8 ff 03 00 00       	call   c01065ad <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c01061ae:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c01061b3:	8b 40 04             	mov    0x4(%eax),%eax
c01061b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01061ba:	c7 44 24 08 98 85 10 	movl   $0xc0108598,0x8(%esp)
c01061c1:	c0 
c01061c2:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c01061c9:	00 
c01061ca:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c01061d1:	e8 87 a9 ff ff       	call   c0100b5d <__panic>

c01061d6 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c01061d6:	55                   	push   %ebp
c01061d7:	89 e5                	mov    %esp,%ebp
c01061d9:	83 ec 18             	sub    $0x18,%esp
    cprintf(" kernel_thread, pid = %d, name = %s\n", current->pid, get_proc_name(current));
c01061dc:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c01061e1:	89 04 24             	mov    %eax,(%esp)
c01061e4:	e8 df f8 ff ff       	call   c0105ac8 <get_proc_name>
c01061e9:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c01061ef:	8b 52 04             	mov    0x4(%edx),%edx
c01061f2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01061f6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061fa:	c7 04 24 b8 85 10 c0 	movl   $0xc01085b8,(%esp)
c0106201:	e8 c1 9f ff ff       	call   c01001c7 <cprintf>
	schedule();
c0106206:	e8 a2 03 00 00       	call   c01065ad <schedule>
    cprintf(" kernel_thread, pid = %d, name = %s , arg  %s \n", current->pid, get_proc_name(current), (const char *)arg);
c010620b:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106210:	89 04 24             	mov    %eax,(%esp)
c0106213:	e8 b0 f8 ff ff       	call   c0105ac8 <get_proc_name>
c0106218:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c010621e:	8b 52 04             	mov    0x4(%edx),%edx
c0106221:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0106224:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106228:	89 44 24 08          	mov    %eax,0x8(%esp)
c010622c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106230:	c7 04 24 e0 85 10 c0 	movl   $0xc01085e0,(%esp)
c0106237:	e8 8b 9f ff ff       	call   c01001c7 <cprintf>
	schedule();
c010623c:	e8 6c 03 00 00       	call   c01065ad <schedule>
    cprintf(" kernel_thread, pid = %d, name = %s ,  en.., Bye, Bye. :)\n",current->pid, get_proc_name(current));
c0106241:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106246:	89 04 24             	mov    %eax,(%esp)
c0106249:	e8 7a f8 ff ff       	call   c0105ac8 <get_proc_name>
c010624e:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c0106254:	8b 52 04             	mov    0x4(%edx),%edx
c0106257:	89 44 24 08          	mov    %eax,0x8(%esp)
c010625b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010625f:	c7 04 24 10 86 10 c0 	movl   $0xc0108610,(%esp)
c0106266:	e8 5c 9f ff ff       	call   c01001c7 <cprintf>
    return 0;
c010626b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106270:	c9                   	leave  
c0106271:	c3                   	ret    

c0106272 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0106272:	55                   	push   %ebp
c0106273:	89 e5                	mov    %esp,%ebp
c0106275:	83 ec 28             	sub    $0x28,%esp
c0106278:	c7 45 e8 d0 d9 11 c0 	movl   $0xc011d9d0,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010627f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106282:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106285:	89 50 04             	mov    %edx,0x4(%eax)
c0106288:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010628b:	8b 50 04             	mov    0x4(%eax),%edx
c010628e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106291:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);

    if ((idleproc = alloc_proc()) == NULL) {
c0106293:	e8 93 f7 ff ff       	call   c0105a2b <alloc_proc>
c0106298:	a3 8c d9 11 c0       	mov    %eax,0xc011d98c
c010629d:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062a2:	85 c0                	test   %eax,%eax
c01062a4:	75 1c                	jne    c01062c2 <proc_init+0x50>
        panic("cannot alloc idleproc.\n");
c01062a6:	c7 44 24 08 4b 86 10 	movl   $0xc010864b,0x8(%esp)
c01062ad:	c0 
c01062ae:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c01062b5:	00 
c01062b6:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c01062bd:	e8 9b a8 ff ff       	call   c0100b5d <__panic>
    }

    idleproc->pid = 0;
c01062c2:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c01062ce:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062d3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c01062d9:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062de:	ba 00 a0 11 c0       	mov    $0xc011a000,%edx
c01062e3:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c01062e6:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062eb:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c01062f2:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01062f7:	c7 44 24 04 63 86 10 	movl   $0xc0108663,0x4(%esp)
c01062fe:	c0 
c01062ff:	89 04 24             	mov    %eax,(%esp)
c0106302:	e8 7e f7 ff ff       	call   c0105a85 <set_proc_name>
    nr_process ++;
c0106307:	a1 a0 d9 11 c0       	mov    0xc011d9a0,%eax
c010630c:	83 c0 01             	add    $0x1,%eax
c010630f:	a3 a0 d9 11 c0       	mov    %eax,0xc011d9a0

    current = idleproc;
c0106314:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c0106319:	a3 9c d9 11 c0       	mov    %eax,0xc011d99c

    int pid1= kernel_thread(init_main, "init main1: Hello world!!", 0);
c010631e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106325:	00 
c0106326:	c7 44 24 04 68 86 10 	movl   $0xc0108668,0x4(%esp)
c010632d:	c0 
c010632e:	c7 04 24 d6 61 10 c0 	movl   $0xc01061d6,(%esp)
c0106335:	e8 b0 f9 ff ff       	call   c0105cea <kernel_thread>
c010633a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int pid2= kernel_thread(init_main, "init main2: Hello world!!", 0);
c010633d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106344:	00 
c0106345:	c7 44 24 04 82 86 10 	movl   $0xc0108682,0x4(%esp)
c010634c:	c0 
c010634d:	c7 04 24 d6 61 10 c0 	movl   $0xc01061d6,(%esp)
c0106354:	e8 91 f9 ff ff       	call   c0105cea <kernel_thread>
c0106359:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int pid3= kernel_thread(init_main, "init main3: Hello world!!", 0);
c010635c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106363:	00 
c0106364:	c7 44 24 04 9c 86 10 	movl   $0xc010869c,0x4(%esp)
c010636b:	c0 
c010636c:	c7 04 24 d6 61 10 c0 	movl   $0xc01061d6,(%esp)
c0106373:	e8 72 f9 ff ff       	call   c0105cea <kernel_thread>
c0106378:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid1 <= 0 || pid2<=0 || pid3<=0) {
c010637b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010637f:	7e 0c                	jle    c010638d <proc_init+0x11b>
c0106381:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106385:	7e 06                	jle    c010638d <proc_init+0x11b>
c0106387:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010638b:	7f 1c                	jg     c01063a9 <proc_init+0x137>
        panic("create kernel thread init_main1 or 2 failed.\n");
c010638d:	c7 44 24 08 b8 86 10 	movl   $0xc01086b8,0x8(%esp)
c0106394:	c0 
c0106395:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c010639c:	00 
c010639d:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c01063a4:	e8 b4 a7 ff ff       	call   c0100b5d <__panic>
    }

    initproc1 = find_proc(pid1);
c01063a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063ac:	89 04 24             	mov    %eax,(%esp)
c01063af:	e8 db f8 ff ff       	call   c0105c8f <find_proc>
c01063b4:	a3 90 d9 11 c0       	mov    %eax,0xc011d990
	initproc2 = find_proc(pid2);
c01063b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063bc:	89 04 24             	mov    %eax,(%esp)
c01063bf:	e8 cb f8 ff ff       	call   c0105c8f <find_proc>
c01063c4:	a3 94 d9 11 c0       	mov    %eax,0xc011d994
    initproc3 = find_proc(pid3);
c01063c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063cc:	89 04 24             	mov    %eax,(%esp)
c01063cf:	e8 bb f8 ff ff       	call   c0105c8f <find_proc>
c01063d4:	a3 98 d9 11 c0       	mov    %eax,0xc011d998
    set_proc_name(initproc1, "init1");
c01063d9:	a1 90 d9 11 c0       	mov    0xc011d990,%eax
c01063de:	c7 44 24 04 e6 86 10 	movl   $0xc01086e6,0x4(%esp)
c01063e5:	c0 
c01063e6:	89 04 24             	mov    %eax,(%esp)
c01063e9:	e8 97 f6 ff ff       	call   c0105a85 <set_proc_name>
	set_proc_name(initproc2, "init2");
c01063ee:	a1 94 d9 11 c0       	mov    0xc011d994,%eax
c01063f3:	c7 44 24 04 ec 86 10 	movl   $0xc01086ec,0x4(%esp)
c01063fa:	c0 
c01063fb:	89 04 24             	mov    %eax,(%esp)
c01063fe:	e8 82 f6 ff ff       	call   c0105a85 <set_proc_name>
    set_proc_name(initproc3, "init3");
c0106403:	a1 98 d9 11 c0       	mov    0xc011d998,%eax
c0106408:	c7 44 24 04 f2 86 10 	movl   $0xc01086f2,0x4(%esp)
c010640f:	c0 
c0106410:	89 04 24             	mov    %eax,(%esp)
c0106413:	e8 6d f6 ff ff       	call   c0105a85 <set_proc_name>
    cprintf("proc_init:: Created kernel thread init_main--> pid: %d, name: %s\n",initproc1->pid, initproc1->name);
c0106418:	a1 90 d9 11 c0       	mov    0xc011d990,%eax
c010641d:	8d 50 48             	lea    0x48(%eax),%edx
c0106420:	a1 90 d9 11 c0       	mov    0xc011d990,%eax
c0106425:	8b 40 04             	mov    0x4(%eax),%eax
c0106428:	89 54 24 08          	mov    %edx,0x8(%esp)
c010642c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106430:	c7 04 24 f8 86 10 c0 	movl   $0xc01086f8,(%esp)
c0106437:	e8 8b 9d ff ff       	call   c01001c7 <cprintf>
	cprintf("proc_init:: Created kernel thread init_main--> pid: %d, name: %s\n",initproc2->pid, initproc2->name);
c010643c:	a1 94 d9 11 c0       	mov    0xc011d994,%eax
c0106441:	8d 50 48             	lea    0x48(%eax),%edx
c0106444:	a1 94 d9 11 c0       	mov    0xc011d994,%eax
c0106449:	8b 40 04             	mov    0x4(%eax),%eax
c010644c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106450:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106454:	c7 04 24 f8 86 10 c0 	movl   $0xc01086f8,(%esp)
c010645b:	e8 67 9d ff ff       	call   c01001c7 <cprintf>
    cprintf("proc_init:: Created kernel thread init_main--> pid: %d, name: %s\n",initproc3->pid, initproc3->name);
c0106460:	a1 98 d9 11 c0       	mov    0xc011d998,%eax
c0106465:	8d 50 48             	lea    0x48(%eax),%edx
c0106468:	a1 98 d9 11 c0       	mov    0xc011d998,%eax
c010646d:	8b 40 04             	mov    0x4(%eax),%eax
c0106470:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106474:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106478:	c7 04 24 f8 86 10 c0 	movl   $0xc01086f8,(%esp)
c010647f:	e8 43 9d ff ff       	call   c01001c7 <cprintf>
    assert(idleproc != NULL && idleproc->pid == 0);
c0106484:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c0106489:	85 c0                	test   %eax,%eax
c010648b:	74 0c                	je     c0106499 <proc_init+0x227>
c010648d:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c0106492:	8b 40 04             	mov    0x4(%eax),%eax
c0106495:	85 c0                	test   %eax,%eax
c0106497:	74 24                	je     c01064bd <proc_init+0x24b>
c0106499:	c7 44 24 0c 3c 87 10 	movl   $0xc010873c,0xc(%esp)
c01064a0:	c0 
c01064a1:	c7 44 24 08 63 87 10 	movl   $0xc0108763,0x8(%esp)
c01064a8:	c0 
c01064a9:	c7 44 24 04 b0 01 00 	movl   $0x1b0,0x4(%esp)
c01064b0:	00 
c01064b1:	c7 04 24 f8 84 10 c0 	movl   $0xc01084f8,(%esp)
c01064b8:	e8 a0 a6 ff ff       	call   c0100b5d <__panic>
}
c01064bd:	c9                   	leave  
c01064be:	c3                   	ret    

c01064bf <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c01064bf:	55                   	push   %ebp
c01064c0:	89 e5                	mov    %esp,%ebp
c01064c2:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c01064c5:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c01064ca:	8b 40 10             	mov    0x10(%eax),%eax
c01064cd:	85 c0                	test   %eax,%eax
c01064cf:	74 07                	je     c01064d8 <cpu_idle+0x19>
            schedule();
c01064d1:	e8 d7 00 00 00       	call   c01065ad <schedule>
        }
    }
c01064d6:	eb ed                	jmp    c01064c5 <cpu_idle+0x6>
c01064d8:	eb eb                	jmp    c01064c5 <cpu_idle+0x6>

c01064da <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01064da:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c01064de:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c01064e0:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c01064e3:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c01064e6:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01064e9:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01064ec:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01064ef:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01064f2:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01064f5:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01064f9:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01064fc:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01064ff:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c0106502:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c0106505:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c0106508:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010650b:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010650e:	ff 30                	pushl  (%eax)

    ret
c0106510:	c3                   	ret    

c0106511 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0106511:	55                   	push   %ebp
c0106512:	89 e5                	mov    %esp,%ebp
c0106514:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106517:	9c                   	pushf  
c0106518:	58                   	pop    %eax
c0106519:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010651c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010651f:	25 00 02 00 00       	and    $0x200,%eax
c0106524:	85 c0                	test   %eax,%eax
c0106526:	74 0c                	je     c0106534 <__intr_save+0x23>
        intr_disable();
c0106528:	e8 13 b0 ff ff       	call   c0101540 <intr_disable>
        return 1;
c010652d:	b8 01 00 00 00       	mov    $0x1,%eax
c0106532:	eb 05                	jmp    c0106539 <__intr_save+0x28>
    }
    return 0;
c0106534:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106539:	c9                   	leave  
c010653a:	c3                   	ret    

c010653b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010653b:	55                   	push   %ebp
c010653c:	89 e5                	mov    %esp,%ebp
c010653e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0106541:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106545:	74 05                	je     c010654c <__intr_restore+0x11>
        intr_enable();
c0106547:	e8 ee af ff ff       	call   c010153a <intr_enable>
    }
}
c010654c:	c9                   	leave  
c010654d:	c3                   	ret    

c010654e <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010654e:	55                   	push   %ebp
c010654f:	89 e5                	mov    %esp,%ebp
c0106551:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0106554:	8b 45 08             	mov    0x8(%ebp),%eax
c0106557:	8b 00                	mov    (%eax),%eax
c0106559:	83 f8 03             	cmp    $0x3,%eax
c010655c:	74 0a                	je     c0106568 <wakeup_proc+0x1a>
c010655e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106561:	8b 00                	mov    (%eax),%eax
c0106563:	83 f8 02             	cmp    $0x2,%eax
c0106566:	75 24                	jne    c010658c <wakeup_proc+0x3e>
c0106568:	c7 44 24 0c 78 87 10 	movl   $0xc0108778,0xc(%esp)
c010656f:	c0 
c0106570:	c7 44 24 08 b3 87 10 	movl   $0xc01087b3,0x8(%esp)
c0106577:	c0 
c0106578:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010657f:	00 
c0106580:	c7 04 24 c8 87 10 c0 	movl   $0xc01087c8,(%esp)
c0106587:	e8 d1 a5 ff ff       	call   c0100b5d <__panic>
    proc->state = PROC_RUNNABLE;
c010658c:	8b 45 08             	mov    0x8(%ebp),%eax
c010658f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    cprintf(" wakeup_proc: proc pid %d will be waken up\n", proc->pid);
c0106595:	8b 45 08             	mov    0x8(%ebp),%eax
c0106598:	8b 40 04             	mov    0x4(%eax),%eax
c010659b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010659f:	c7 04 24 e0 87 10 c0 	movl   $0xc01087e0,(%esp)
c01065a6:	e8 1c 9c ff ff       	call   c01001c7 <cprintf>
}
c01065ab:	c9                   	leave  
c01065ac:	c3                   	ret    

c01065ad <schedule>:

void
schedule(void) {
c01065ad:	55                   	push   %ebp
c01065ae:	89 e5                	mov    %esp,%ebp
c01065b0:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c01065b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c01065ba:	e8 52 ff ff ff       	call   c0106511 <__intr_save>
c01065bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c01065c2:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c01065c7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c01065ce:	8b 15 9c d9 11 c0    	mov    0xc011d99c,%edx
c01065d4:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c01065d9:	39 c2                	cmp    %eax,%edx
c01065db:	74 0a                	je     c01065e7 <schedule+0x3a>
c01065dd:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c01065e2:	83 c0 58             	add    $0x58,%eax
c01065e5:	eb 05                	jmp    c01065ec <schedule+0x3f>
c01065e7:	b8 d0 d9 11 c0       	mov    $0xc011d9d0,%eax
c01065ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c01065ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01065fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065fe:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0106601:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106604:	81 7d f4 d0 d9 11 c0 	cmpl   $0xc011d9d0,-0xc(%ebp)
c010660b:	74 15                	je     c0106622 <schedule+0x75>
                next = le2proc(le, list_link);
c010660d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106610:	83 e8 58             	sub    $0x58,%eax
c0106613:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0106616:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106619:	8b 00                	mov    (%eax),%eax
c010661b:	83 f8 02             	cmp    $0x2,%eax
c010661e:	75 02                	jne    c0106622 <schedule+0x75>
                    break;
c0106620:	eb 08                	jmp    c010662a <schedule+0x7d>
                }
            }
        } while (le != last);
c0106622:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106625:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0106628:	75 cb                	jne    c01065f5 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010662a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010662e:	74 0a                	je     c010663a <schedule+0x8d>
c0106630:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106633:	8b 00                	mov    (%eax),%eax
c0106635:	83 f8 02             	cmp    $0x2,%eax
c0106638:	74 08                	je     c0106642 <schedule+0x95>
            next = idleproc;
c010663a:	a1 8c d9 11 c0       	mov    0xc011d98c,%eax
c010663f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0106642:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106645:	8b 40 08             	mov    0x8(%eax),%eax
c0106648:	8d 50 01             	lea    0x1(%eax),%edx
c010664b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010664e:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0106651:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106656:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106659:	74 39                	je     c0106694 <schedule+0xe7>
            cprintf(" schedule: proc pid %d will be ready\n", current->pid);
c010665b:	a1 9c d9 11 c0       	mov    0xc011d99c,%eax
c0106660:	8b 40 04             	mov    0x4(%eax),%eax
c0106663:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106667:	c7 04 24 0c 88 10 c0 	movl   $0xc010880c,(%esp)
c010666e:	e8 54 9b ff ff       	call   c01001c7 <cprintf>
            cprintf(" schedule: proc pid %d will be running\n", next->pid);
c0106673:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106676:	8b 40 04             	mov    0x4(%eax),%eax
c0106679:	89 44 24 04          	mov    %eax,0x4(%esp)
c010667d:	c7 04 24 34 88 10 c0 	movl   $0xc0108834,(%esp)
c0106684:	e8 3e 9b ff ff       	call   c01001c7 <cprintf>
            proc_run(next);
c0106689:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010668c:	89 04 24             	mov    %eax,(%esp)
c010668f:	e8 6e f5 ff ff       	call   c0105c02 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c0106694:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106697:	89 04 24             	mov    %eax,(%esp)
c010669a:	e8 9c fe ff ff       	call   c010653b <__intr_restore>
}
c010669f:	c9                   	leave  
c01066a0:	c3                   	ret    

c01066a1 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01066a1:	55                   	push   %ebp
c01066a2:	89 e5                	mov    %esp,%ebp
c01066a4:	83 ec 58             	sub    $0x58,%esp
c01066a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01066aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01066ad:	8b 45 14             	mov    0x14(%ebp),%eax
c01066b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01066b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01066b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01066b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01066bc:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01066bf:	8b 45 18             	mov    0x18(%ebp),%eax
c01066c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01066c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01066cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01066ce:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01066d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01066d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066db:	74 1c                	je     c01066f9 <printnum+0x58>
c01066dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066e0:	ba 00 00 00 00       	mov    $0x0,%edx
c01066e5:	f7 75 e4             	divl   -0x1c(%ebp)
c01066e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01066eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066ee:	ba 00 00 00 00       	mov    $0x0,%edx
c01066f3:	f7 75 e4             	divl   -0x1c(%ebp)
c01066f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01066ff:	f7 75 e4             	divl   -0x1c(%ebp)
c0106702:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106705:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106708:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010670b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010670e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106711:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106717:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010671a:	8b 45 18             	mov    0x18(%ebp),%eax
c010671d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106722:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106725:	77 56                	ja     c010677d <printnum+0xdc>
c0106727:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010672a:	72 05                	jb     c0106731 <printnum+0x90>
c010672c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010672f:	77 4c                	ja     c010677d <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106731:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106734:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106737:	8b 45 20             	mov    0x20(%ebp),%eax
c010673a:	89 44 24 18          	mov    %eax,0x18(%esp)
c010673e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106742:	8b 45 18             	mov    0x18(%ebp),%eax
c0106745:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106749:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010674c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010674f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106753:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106757:	8b 45 0c             	mov    0xc(%ebp),%eax
c010675a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010675e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106761:	89 04 24             	mov    %eax,(%esp)
c0106764:	e8 38 ff ff ff       	call   c01066a1 <printnum>
c0106769:	eb 1c                	jmp    c0106787 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010676b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010676e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106772:	8b 45 20             	mov    0x20(%ebp),%eax
c0106775:	89 04 24             	mov    %eax,(%esp)
c0106778:	8b 45 08             	mov    0x8(%ebp),%eax
c010677b:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010677d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0106781:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106785:	7f e4                	jg     c010676b <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106787:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010678a:	05 dc 88 10 c0       	add    $0xc01088dc,%eax
c010678f:	0f b6 00             	movzbl (%eax),%eax
c0106792:	0f be c0             	movsbl %al,%eax
c0106795:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106798:	89 54 24 04          	mov    %edx,0x4(%esp)
c010679c:	89 04 24             	mov    %eax,(%esp)
c010679f:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a2:	ff d0                	call   *%eax
}
c01067a4:	c9                   	leave  
c01067a5:	c3                   	ret    

c01067a6 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01067a6:	55                   	push   %ebp
c01067a7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01067a9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067ad:	7e 14                	jle    c01067c3 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01067af:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b2:	8b 00                	mov    (%eax),%eax
c01067b4:	8d 48 08             	lea    0x8(%eax),%ecx
c01067b7:	8b 55 08             	mov    0x8(%ebp),%edx
c01067ba:	89 0a                	mov    %ecx,(%edx)
c01067bc:	8b 50 04             	mov    0x4(%eax),%edx
c01067bf:	8b 00                	mov    (%eax),%eax
c01067c1:	eb 30                	jmp    c01067f3 <getuint+0x4d>
    }
    else if (lflag) {
c01067c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01067c7:	74 16                	je     c01067df <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01067c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01067cc:	8b 00                	mov    (%eax),%eax
c01067ce:	8d 48 04             	lea    0x4(%eax),%ecx
c01067d1:	8b 55 08             	mov    0x8(%ebp),%edx
c01067d4:	89 0a                	mov    %ecx,(%edx)
c01067d6:	8b 00                	mov    (%eax),%eax
c01067d8:	ba 00 00 00 00       	mov    $0x0,%edx
c01067dd:	eb 14                	jmp    c01067f3 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01067df:	8b 45 08             	mov    0x8(%ebp),%eax
c01067e2:	8b 00                	mov    (%eax),%eax
c01067e4:	8d 48 04             	lea    0x4(%eax),%ecx
c01067e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01067ea:	89 0a                	mov    %ecx,(%edx)
c01067ec:	8b 00                	mov    (%eax),%eax
c01067ee:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01067f3:	5d                   	pop    %ebp
c01067f4:	c3                   	ret    

c01067f5 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01067f5:	55                   	push   %ebp
c01067f6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01067f8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067fc:	7e 14                	jle    c0106812 <getint+0x1d>
        return va_arg(*ap, long long);
c01067fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106801:	8b 00                	mov    (%eax),%eax
c0106803:	8d 48 08             	lea    0x8(%eax),%ecx
c0106806:	8b 55 08             	mov    0x8(%ebp),%edx
c0106809:	89 0a                	mov    %ecx,(%edx)
c010680b:	8b 50 04             	mov    0x4(%eax),%edx
c010680e:	8b 00                	mov    (%eax),%eax
c0106810:	eb 28                	jmp    c010683a <getint+0x45>
    }
    else if (lflag) {
c0106812:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106816:	74 12                	je     c010682a <getint+0x35>
        return va_arg(*ap, long);
c0106818:	8b 45 08             	mov    0x8(%ebp),%eax
c010681b:	8b 00                	mov    (%eax),%eax
c010681d:	8d 48 04             	lea    0x4(%eax),%ecx
c0106820:	8b 55 08             	mov    0x8(%ebp),%edx
c0106823:	89 0a                	mov    %ecx,(%edx)
c0106825:	8b 00                	mov    (%eax),%eax
c0106827:	99                   	cltd   
c0106828:	eb 10                	jmp    c010683a <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010682a:	8b 45 08             	mov    0x8(%ebp),%eax
c010682d:	8b 00                	mov    (%eax),%eax
c010682f:	8d 48 04             	lea    0x4(%eax),%ecx
c0106832:	8b 55 08             	mov    0x8(%ebp),%edx
c0106835:	89 0a                	mov    %ecx,(%edx)
c0106837:	8b 00                	mov    (%eax),%eax
c0106839:	99                   	cltd   
    }
}
c010683a:	5d                   	pop    %ebp
c010683b:	c3                   	ret    

c010683c <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010683c:	55                   	push   %ebp
c010683d:	89 e5                	mov    %esp,%ebp
c010683f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106842:	8d 45 14             	lea    0x14(%ebp),%eax
c0106845:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0106848:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010684b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010684f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106852:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106856:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106859:	89 44 24 04          	mov    %eax,0x4(%esp)
c010685d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106860:	89 04 24             	mov    %eax,(%esp)
c0106863:	e8 02 00 00 00       	call   c010686a <vprintfmt>
    va_end(ap);
}
c0106868:	c9                   	leave  
c0106869:	c3                   	ret    

c010686a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010686a:	55                   	push   %ebp
c010686b:	89 e5                	mov    %esp,%ebp
c010686d:	56                   	push   %esi
c010686e:	53                   	push   %ebx
c010686f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106872:	eb 18                	jmp    c010688c <vprintfmt+0x22>
            if (ch == '\0') {
c0106874:	85 db                	test   %ebx,%ebx
c0106876:	75 05                	jne    c010687d <vprintfmt+0x13>
                return;
c0106878:	e9 d1 03 00 00       	jmp    c0106c4e <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010687d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106880:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106884:	89 1c 24             	mov    %ebx,(%esp)
c0106887:	8b 45 08             	mov    0x8(%ebp),%eax
c010688a:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010688c:	8b 45 10             	mov    0x10(%ebp),%eax
c010688f:	8d 50 01             	lea    0x1(%eax),%edx
c0106892:	89 55 10             	mov    %edx,0x10(%ebp)
c0106895:	0f b6 00             	movzbl (%eax),%eax
c0106898:	0f b6 d8             	movzbl %al,%ebx
c010689b:	83 fb 25             	cmp    $0x25,%ebx
c010689e:	75 d4                	jne    c0106874 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01068a0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01068a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01068ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01068b1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01068b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01068bb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01068be:	8b 45 10             	mov    0x10(%ebp),%eax
c01068c1:	8d 50 01             	lea    0x1(%eax),%edx
c01068c4:	89 55 10             	mov    %edx,0x10(%ebp)
c01068c7:	0f b6 00             	movzbl (%eax),%eax
c01068ca:	0f b6 d8             	movzbl %al,%ebx
c01068cd:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01068d0:	83 f8 55             	cmp    $0x55,%eax
c01068d3:	0f 87 44 03 00 00    	ja     c0106c1d <vprintfmt+0x3b3>
c01068d9:	8b 04 85 00 89 10 c0 	mov    -0x3fef7700(,%eax,4),%eax
c01068e0:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01068e2:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01068e6:	eb d6                	jmp    c01068be <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01068e8:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01068ec:	eb d0                	jmp    c01068be <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01068ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01068f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01068f8:	89 d0                	mov    %edx,%eax
c01068fa:	c1 e0 02             	shl    $0x2,%eax
c01068fd:	01 d0                	add    %edx,%eax
c01068ff:	01 c0                	add    %eax,%eax
c0106901:	01 d8                	add    %ebx,%eax
c0106903:	83 e8 30             	sub    $0x30,%eax
c0106906:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106909:	8b 45 10             	mov    0x10(%ebp),%eax
c010690c:	0f b6 00             	movzbl (%eax),%eax
c010690f:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106912:	83 fb 2f             	cmp    $0x2f,%ebx
c0106915:	7e 0b                	jle    c0106922 <vprintfmt+0xb8>
c0106917:	83 fb 39             	cmp    $0x39,%ebx
c010691a:	7f 06                	jg     c0106922 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010691c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0106920:	eb d3                	jmp    c01068f5 <vprintfmt+0x8b>
            goto process_precision;
c0106922:	eb 33                	jmp    c0106957 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0106924:	8b 45 14             	mov    0x14(%ebp),%eax
c0106927:	8d 50 04             	lea    0x4(%eax),%edx
c010692a:	89 55 14             	mov    %edx,0x14(%ebp)
c010692d:	8b 00                	mov    (%eax),%eax
c010692f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106932:	eb 23                	jmp    c0106957 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0106934:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106938:	79 0c                	jns    c0106946 <vprintfmt+0xdc>
                width = 0;
c010693a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106941:	e9 78 ff ff ff       	jmp    c01068be <vprintfmt+0x54>
c0106946:	e9 73 ff ff ff       	jmp    c01068be <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010694b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106952:	e9 67 ff ff ff       	jmp    c01068be <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0106957:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010695b:	79 12                	jns    c010696f <vprintfmt+0x105>
                width = precision, precision = -1;
c010695d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106960:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106963:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010696a:	e9 4f ff ff ff       	jmp    c01068be <vprintfmt+0x54>
c010696f:	e9 4a ff ff ff       	jmp    c01068be <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106974:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0106978:	e9 41 ff ff ff       	jmp    c01068be <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010697d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106980:	8d 50 04             	lea    0x4(%eax),%edx
c0106983:	89 55 14             	mov    %edx,0x14(%ebp)
c0106986:	8b 00                	mov    (%eax),%eax
c0106988:	8b 55 0c             	mov    0xc(%ebp),%edx
c010698b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010698f:	89 04 24             	mov    %eax,(%esp)
c0106992:	8b 45 08             	mov    0x8(%ebp),%eax
c0106995:	ff d0                	call   *%eax
            break;
c0106997:	e9 ac 02 00 00       	jmp    c0106c48 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010699c:	8b 45 14             	mov    0x14(%ebp),%eax
c010699f:	8d 50 04             	lea    0x4(%eax),%edx
c01069a2:	89 55 14             	mov    %edx,0x14(%ebp)
c01069a5:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01069a7:	85 db                	test   %ebx,%ebx
c01069a9:	79 02                	jns    c01069ad <vprintfmt+0x143>
                err = -err;
c01069ab:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01069ad:	83 fb 06             	cmp    $0x6,%ebx
c01069b0:	7f 0b                	jg     c01069bd <vprintfmt+0x153>
c01069b2:	8b 34 9d c0 88 10 c0 	mov    -0x3fef7740(,%ebx,4),%esi
c01069b9:	85 f6                	test   %esi,%esi
c01069bb:	75 23                	jne    c01069e0 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01069bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01069c1:	c7 44 24 08 ed 88 10 	movl   $0xc01088ed,0x8(%esp)
c01069c8:	c0 
c01069c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01069d3:	89 04 24             	mov    %eax,(%esp)
c01069d6:	e8 61 fe ff ff       	call   c010683c <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01069db:	e9 68 02 00 00       	jmp    c0106c48 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01069e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01069e4:	c7 44 24 08 f6 88 10 	movl   $0xc01088f6,0x8(%esp)
c01069eb:	c0 
c01069ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01069f6:	89 04 24             	mov    %eax,(%esp)
c01069f9:	e8 3e fe ff ff       	call   c010683c <printfmt>
            }
            break;
c01069fe:	e9 45 02 00 00       	jmp    c0106c48 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106a03:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a06:	8d 50 04             	lea    0x4(%eax),%edx
c0106a09:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a0c:	8b 30                	mov    (%eax),%esi
c0106a0e:	85 f6                	test   %esi,%esi
c0106a10:	75 05                	jne    c0106a17 <vprintfmt+0x1ad>
                p = "(null)";
c0106a12:	be f9 88 10 c0       	mov    $0xc01088f9,%esi
            }
            if (width > 0 && padc != '-') {
c0106a17:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a1b:	7e 3e                	jle    c0106a5b <vprintfmt+0x1f1>
c0106a1d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106a21:	74 38                	je     c0106a5b <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a23:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0106a26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a2d:	89 34 24             	mov    %esi,(%esp)
c0106a30:	e8 ed 03 00 00       	call   c0106e22 <strnlen>
c0106a35:	29 c3                	sub    %eax,%ebx
c0106a37:	89 d8                	mov    %ebx,%eax
c0106a39:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106a3c:	eb 17                	jmp    c0106a55 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0106a3e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106a42:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a45:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a49:	89 04 24             	mov    %eax,(%esp)
c0106a4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a4f:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a51:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106a55:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a59:	7f e3                	jg     c0106a3e <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a5b:	eb 38                	jmp    c0106a95 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106a5d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106a61:	74 1f                	je     c0106a82 <vprintfmt+0x218>
c0106a63:	83 fb 1f             	cmp    $0x1f,%ebx
c0106a66:	7e 05                	jle    c0106a6d <vprintfmt+0x203>
c0106a68:	83 fb 7e             	cmp    $0x7e,%ebx
c0106a6b:	7e 15                	jle    c0106a82 <vprintfmt+0x218>
                    putch('?', putdat);
c0106a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a74:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106a7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a7e:	ff d0                	call   *%eax
c0106a80:	eb 0f                	jmp    c0106a91 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0106a82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a89:	89 1c 24             	mov    %ebx,(%esp)
c0106a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a8f:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a91:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106a95:	89 f0                	mov    %esi,%eax
c0106a97:	8d 70 01             	lea    0x1(%eax),%esi
c0106a9a:	0f b6 00             	movzbl (%eax),%eax
c0106a9d:	0f be d8             	movsbl %al,%ebx
c0106aa0:	85 db                	test   %ebx,%ebx
c0106aa2:	74 10                	je     c0106ab4 <vprintfmt+0x24a>
c0106aa4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106aa8:	78 b3                	js     c0106a5d <vprintfmt+0x1f3>
c0106aaa:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0106aae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106ab2:	79 a9                	jns    c0106a5d <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106ab4:	eb 17                	jmp    c0106acd <vprintfmt+0x263>
                putch(' ', putdat);
c0106ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106abd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106ac4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ac7:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106ac9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106acd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106ad1:	7f e3                	jg     c0106ab6 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0106ad3:	e9 70 01 00 00       	jmp    c0106c48 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106ad8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106adf:	8d 45 14             	lea    0x14(%ebp),%eax
c0106ae2:	89 04 24             	mov    %eax,(%esp)
c0106ae5:	e8 0b fd ff ff       	call   c01067f5 <getint>
c0106aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106aed:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106af6:	85 d2                	test   %edx,%edx
c0106af8:	79 26                	jns    c0106b20 <vprintfmt+0x2b6>
                putch('-', putdat);
c0106afa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106afd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b01:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b0b:	ff d0                	call   *%eax
                num = -(long long)num;
c0106b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b10:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b13:	f7 d8                	neg    %eax
c0106b15:	83 d2 00             	adc    $0x0,%edx
c0106b18:	f7 da                	neg    %edx
c0106b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b1d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106b20:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b27:	e9 a8 00 00 00       	jmp    c0106bd4 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106b2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b33:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b36:	89 04 24             	mov    %eax,(%esp)
c0106b39:	e8 68 fc ff ff       	call   c01067a6 <getuint>
c0106b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b41:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106b44:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b4b:	e9 84 00 00 00       	jmp    c0106bd4 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b57:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b5a:	89 04 24             	mov    %eax,(%esp)
c0106b5d:	e8 44 fc ff ff       	call   c01067a6 <getuint>
c0106b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b65:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106b68:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106b6f:	eb 63                	jmp    c0106bd4 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0106b71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b78:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106b7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b82:	ff d0                	call   *%eax
            putch('x', putdat);
c0106b84:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b8b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106b92:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b95:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106b97:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b9a:	8d 50 04             	lea    0x4(%eax),%edx
c0106b9d:	89 55 14             	mov    %edx,0x14(%ebp)
c0106ba0:	8b 00                	mov    (%eax),%eax
c0106ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ba5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106bac:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106bb3:	eb 1f                	jmp    c0106bd4 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106bb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bbc:	8d 45 14             	lea    0x14(%ebp),%eax
c0106bbf:	89 04 24             	mov    %eax,(%esp)
c0106bc2:	e8 df fb ff ff       	call   c01067a6 <getuint>
c0106bc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bca:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106bcd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106bd4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bdb:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106bdf:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106be2:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106be6:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106bf4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c02:	89 04 24             	mov    %eax,(%esp)
c0106c05:	e8 97 fa ff ff       	call   c01066a1 <printnum>
            break;
c0106c0a:	eb 3c                	jmp    c0106c48 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c13:	89 1c 24             	mov    %ebx,(%esp)
c0106c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c19:	ff d0                	call   *%eax
            break;
c0106c1b:	eb 2b                	jmp    c0106c48 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c24:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c2e:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106c30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0106c34:	eb 04                	jmp    c0106c3a <vprintfmt+0x3d0>
c0106c36:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0106c3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c3d:	83 e8 01             	sub    $0x1,%eax
c0106c40:	0f b6 00             	movzbl (%eax),%eax
c0106c43:	3c 25                	cmp    $0x25,%al
c0106c45:	75 ef                	jne    c0106c36 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0106c47:	90                   	nop
        }
    }
c0106c48:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106c49:	e9 3e fc ff ff       	jmp    c010688c <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0106c4e:	83 c4 40             	add    $0x40,%esp
c0106c51:	5b                   	pop    %ebx
c0106c52:	5e                   	pop    %esi
c0106c53:	5d                   	pop    %ebp
c0106c54:	c3                   	ret    

c0106c55 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106c55:	55                   	push   %ebp
c0106c56:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106c58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c5b:	8b 40 08             	mov    0x8(%eax),%eax
c0106c5e:	8d 50 01             	lea    0x1(%eax),%edx
c0106c61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c64:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106c67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c6a:	8b 10                	mov    (%eax),%edx
c0106c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c6f:	8b 40 04             	mov    0x4(%eax),%eax
c0106c72:	39 c2                	cmp    %eax,%edx
c0106c74:	73 12                	jae    c0106c88 <sprintputch+0x33>
        *b->buf ++ = ch;
c0106c76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c79:	8b 00                	mov    (%eax),%eax
c0106c7b:	8d 48 01             	lea    0x1(%eax),%ecx
c0106c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c81:	89 0a                	mov    %ecx,(%edx)
c0106c83:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c86:	88 10                	mov    %dl,(%eax)
    }
}
c0106c88:	5d                   	pop    %ebp
c0106c89:	c3                   	ret    

c0106c8a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106c8a:	55                   	push   %ebp
c0106c8b:	89 e5                	mov    %esp,%ebp
c0106c8d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106c90:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cab:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cae:	89 04 24             	mov    %eax,(%esp)
c0106cb1:	e8 08 00 00 00       	call   c0106cbe <vsnprintf>
c0106cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106cbc:	c9                   	leave  
c0106cbd:	c3                   	ret    

c0106cbe <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106cbe:	55                   	push   %ebp
c0106cbf:	89 e5                	mov    %esp,%ebp
c0106cc1:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106cca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ccd:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106cd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cd3:	01 d0                	add    %edx,%eax
c0106cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106cdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106ce3:	74 0a                	je     c0106cef <vsnprintf+0x31>
c0106ce5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ceb:	39 c2                	cmp    %eax,%edx
c0106ced:	76 07                	jbe    c0106cf6 <vsnprintf+0x38>
        return -E_INVAL;
c0106cef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106cf4:	eb 2a                	jmp    c0106d20 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106cf6:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d00:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d04:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106d07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d0b:	c7 04 24 55 6c 10 c0 	movl   $0xc0106c55,(%esp)
c0106d12:	e8 53 fb ff ff       	call   c010686a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106d17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d1a:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d20:	c9                   	leave  
c0106d21:	c3                   	ret    

c0106d22 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0106d22:	55                   	push   %ebp
c0106d23:	89 e5                	mov    %esp,%ebp
c0106d25:	57                   	push   %edi
c0106d26:	56                   	push   %esi
c0106d27:	53                   	push   %ebx
c0106d28:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0106d2b:	a1 60 ca 11 c0       	mov    0xc011ca60,%eax
c0106d30:	8b 15 64 ca 11 c0    	mov    0xc011ca64,%edx
c0106d36:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0106d3c:	6b f0 05             	imul   $0x5,%eax,%esi
c0106d3f:	01 f7                	add    %esi,%edi
c0106d41:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c0106d46:	f7 e6                	mul    %esi
c0106d48:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0106d4b:	89 f2                	mov    %esi,%edx
c0106d4d:	83 c0 0b             	add    $0xb,%eax
c0106d50:	83 d2 00             	adc    $0x0,%edx
c0106d53:	89 c7                	mov    %eax,%edi
c0106d55:	83 e7 ff             	and    $0xffffffff,%edi
c0106d58:	89 f9                	mov    %edi,%ecx
c0106d5a:	0f b7 da             	movzwl %dx,%ebx
c0106d5d:	89 0d 60 ca 11 c0    	mov    %ecx,0xc011ca60
c0106d63:	89 1d 64 ca 11 c0    	mov    %ebx,0xc011ca64
    unsigned long long result = (next >> 12);
c0106d69:	a1 60 ca 11 c0       	mov    0xc011ca60,%eax
c0106d6e:	8b 15 64 ca 11 c0    	mov    0xc011ca64,%edx
c0106d74:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106d78:	c1 ea 0c             	shr    $0xc,%edx
c0106d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106d7e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0106d81:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0106d88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106d8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106d91:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d97:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106d9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106d9e:	74 1c                	je     c0106dbc <rand+0x9a>
c0106da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106da3:	ba 00 00 00 00       	mov    $0x0,%edx
c0106da8:	f7 75 dc             	divl   -0x24(%ebp)
c0106dab:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106dae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106db1:	ba 00 00 00 00       	mov    $0x0,%edx
c0106db6:	f7 75 dc             	divl   -0x24(%ebp)
c0106db9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106dbc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106dbf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106dc2:	f7 75 dc             	divl   -0x24(%ebp)
c0106dc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106dc8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106dcb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106dce:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106dd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106dd4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106dd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0106dda:	83 c4 24             	add    $0x24,%esp
c0106ddd:	5b                   	pop    %ebx
c0106dde:	5e                   	pop    %esi
c0106ddf:	5f                   	pop    %edi
c0106de0:	5d                   	pop    %ebp
c0106de1:	c3                   	ret    

c0106de2 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0106de2:	55                   	push   %ebp
c0106de3:	89 e5                	mov    %esp,%ebp
    next = seed;
c0106de5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106de8:	ba 00 00 00 00       	mov    $0x0,%edx
c0106ded:	a3 60 ca 11 c0       	mov    %eax,0xc011ca60
c0106df2:	89 15 64 ca 11 c0    	mov    %edx,0xc011ca64
}
c0106df8:	5d                   	pop    %ebp
c0106df9:	c3                   	ret    

c0106dfa <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0106dfa:	55                   	push   %ebp
c0106dfb:	89 e5                	mov    %esp,%ebp
c0106dfd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106e00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106e07:	eb 04                	jmp    c0106e0d <strlen+0x13>
        cnt ++;
c0106e09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0106e0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e10:	8d 50 01             	lea    0x1(%eax),%edx
c0106e13:	89 55 08             	mov    %edx,0x8(%ebp)
c0106e16:	0f b6 00             	movzbl (%eax),%eax
c0106e19:	84 c0                	test   %al,%al
c0106e1b:	75 ec                	jne    c0106e09 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0106e1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106e20:	c9                   	leave  
c0106e21:	c3                   	ret    

c0106e22 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106e22:	55                   	push   %ebp
c0106e23:	89 e5                	mov    %esp,%ebp
c0106e25:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106e28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106e2f:	eb 04                	jmp    c0106e35 <strnlen+0x13>
        cnt ++;
c0106e31:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0106e35:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106e38:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106e3b:	73 10                	jae    c0106e4d <strnlen+0x2b>
c0106e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e40:	8d 50 01             	lea    0x1(%eax),%edx
c0106e43:	89 55 08             	mov    %edx,0x8(%ebp)
c0106e46:	0f b6 00             	movzbl (%eax),%eax
c0106e49:	84 c0                	test   %al,%al
c0106e4b:	75 e4                	jne    c0106e31 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0106e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106e50:	c9                   	leave  
c0106e51:	c3                   	ret    

c0106e52 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0106e52:	55                   	push   %ebp
c0106e53:	89 e5                	mov    %esp,%ebp
c0106e55:	57                   	push   %edi
c0106e56:	56                   	push   %esi
c0106e57:	83 ec 20             	sub    $0x20,%esp
c0106e5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106e60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e63:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106e66:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e6c:	89 d1                	mov    %edx,%ecx
c0106e6e:	89 c2                	mov    %eax,%edx
c0106e70:	89 ce                	mov    %ecx,%esi
c0106e72:	89 d7                	mov    %edx,%edi
c0106e74:	ac                   	lods   %ds:(%esi),%al
c0106e75:	aa                   	stos   %al,%es:(%edi)
c0106e76:	84 c0                	test   %al,%al
c0106e78:	75 fa                	jne    c0106e74 <strcpy+0x22>
c0106e7a:	89 fa                	mov    %edi,%edx
c0106e7c:	89 f1                	mov    %esi,%ecx
c0106e7e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106e81:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106e84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106e8a:	83 c4 20             	add    $0x20,%esp
c0106e8d:	5e                   	pop    %esi
c0106e8e:	5f                   	pop    %edi
c0106e8f:	5d                   	pop    %ebp
c0106e90:	c3                   	ret    

c0106e91 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0106e91:	55                   	push   %ebp
c0106e92:	89 e5                	mov    %esp,%ebp
c0106e94:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106e97:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106e9d:	eb 21                	jmp    c0106ec0 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0106e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ea2:	0f b6 10             	movzbl (%eax),%edx
c0106ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ea8:	88 10                	mov    %dl,(%eax)
c0106eaa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ead:	0f b6 00             	movzbl (%eax),%eax
c0106eb0:	84 c0                	test   %al,%al
c0106eb2:	74 04                	je     c0106eb8 <strncpy+0x27>
            src ++;
c0106eb4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0106eb8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0106ebc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0106ec0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106ec4:	75 d9                	jne    c0106e9f <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0106ec6:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106ec9:	c9                   	leave  
c0106eca:	c3                   	ret    

c0106ecb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106ecb:	55                   	push   %ebp
c0106ecc:	89 e5                	mov    %esp,%ebp
c0106ece:	57                   	push   %edi
c0106ecf:	56                   	push   %esi
c0106ed0:	83 ec 20             	sub    $0x20,%esp
c0106ed3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ed6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106edc:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0106edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ee5:	89 d1                	mov    %edx,%ecx
c0106ee7:	89 c2                	mov    %eax,%edx
c0106ee9:	89 ce                	mov    %ecx,%esi
c0106eeb:	89 d7                	mov    %edx,%edi
c0106eed:	ac                   	lods   %ds:(%esi),%al
c0106eee:	ae                   	scas   %es:(%edi),%al
c0106eef:	75 08                	jne    c0106ef9 <strcmp+0x2e>
c0106ef1:	84 c0                	test   %al,%al
c0106ef3:	75 f8                	jne    c0106eed <strcmp+0x22>
c0106ef5:	31 c0                	xor    %eax,%eax
c0106ef7:	eb 04                	jmp    c0106efd <strcmp+0x32>
c0106ef9:	19 c0                	sbb    %eax,%eax
c0106efb:	0c 01                	or     $0x1,%al
c0106efd:	89 fa                	mov    %edi,%edx
c0106eff:	89 f1                	mov    %esi,%ecx
c0106f01:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106f04:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106f07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0106f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106f0d:	83 c4 20             	add    $0x20,%esp
c0106f10:	5e                   	pop    %esi
c0106f11:	5f                   	pop    %edi
c0106f12:	5d                   	pop    %ebp
c0106f13:	c3                   	ret    

c0106f14 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106f14:	55                   	push   %ebp
c0106f15:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106f17:	eb 0c                	jmp    c0106f25 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0106f19:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0106f1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106f21:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106f25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106f29:	74 1a                	je     c0106f45 <strncmp+0x31>
c0106f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f2e:	0f b6 00             	movzbl (%eax),%eax
c0106f31:	84 c0                	test   %al,%al
c0106f33:	74 10                	je     c0106f45 <strncmp+0x31>
c0106f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f38:	0f b6 10             	movzbl (%eax),%edx
c0106f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f3e:	0f b6 00             	movzbl (%eax),%eax
c0106f41:	38 c2                	cmp    %al,%dl
c0106f43:	74 d4                	je     c0106f19 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106f45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106f49:	74 18                	je     c0106f63 <strncmp+0x4f>
c0106f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f4e:	0f b6 00             	movzbl (%eax),%eax
c0106f51:	0f b6 d0             	movzbl %al,%edx
c0106f54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f57:	0f b6 00             	movzbl (%eax),%eax
c0106f5a:	0f b6 c0             	movzbl %al,%eax
c0106f5d:	29 c2                	sub    %eax,%edx
c0106f5f:	89 d0                	mov    %edx,%eax
c0106f61:	eb 05                	jmp    c0106f68 <strncmp+0x54>
c0106f63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106f68:	5d                   	pop    %ebp
c0106f69:	c3                   	ret    

c0106f6a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106f6a:	55                   	push   %ebp
c0106f6b:	89 e5                	mov    %esp,%ebp
c0106f6d:	83 ec 04             	sub    $0x4,%esp
c0106f70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f73:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106f76:	eb 14                	jmp    c0106f8c <strchr+0x22>
        if (*s == c) {
c0106f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f7b:	0f b6 00             	movzbl (%eax),%eax
c0106f7e:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0106f81:	75 05                	jne    c0106f88 <strchr+0x1e>
            return (char *)s;
c0106f83:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f86:	eb 13                	jmp    c0106f9b <strchr+0x31>
        }
        s ++;
c0106f88:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0106f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f8f:	0f b6 00             	movzbl (%eax),%eax
c0106f92:	84 c0                	test   %al,%al
c0106f94:	75 e2                	jne    c0106f78 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0106f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106f9b:	c9                   	leave  
c0106f9c:	c3                   	ret    

c0106f9d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106f9d:	55                   	push   %ebp
c0106f9e:	89 e5                	mov    %esp,%ebp
c0106fa0:	83 ec 04             	sub    $0x4,%esp
c0106fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fa6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106fa9:	eb 11                	jmp    c0106fbc <strfind+0x1f>
        if (*s == c) {
c0106fab:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fae:	0f b6 00             	movzbl (%eax),%eax
c0106fb1:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0106fb4:	75 02                	jne    c0106fb8 <strfind+0x1b>
            break;
c0106fb6:	eb 0e                	jmp    c0106fc6 <strfind+0x29>
        }
        s ++;
c0106fb8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0106fbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fbf:	0f b6 00             	movzbl (%eax),%eax
c0106fc2:	84 c0                	test   %al,%al
c0106fc4:	75 e5                	jne    c0106fab <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0106fc6:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106fc9:	c9                   	leave  
c0106fca:	c3                   	ret    

c0106fcb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106fcb:	55                   	push   %ebp
c0106fcc:	89 e5                	mov    %esp,%ebp
c0106fce:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0106fd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106fd8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106fdf:	eb 04                	jmp    c0106fe5 <strtol+0x1a>
        s ++;
c0106fe1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106fe5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fe8:	0f b6 00             	movzbl (%eax),%eax
c0106feb:	3c 20                	cmp    $0x20,%al
c0106fed:	74 f2                	je     c0106fe1 <strtol+0x16>
c0106fef:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ff2:	0f b6 00             	movzbl (%eax),%eax
c0106ff5:	3c 09                	cmp    $0x9,%al
c0106ff7:	74 e8                	je     c0106fe1 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0106ff9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ffc:	0f b6 00             	movzbl (%eax),%eax
c0106fff:	3c 2b                	cmp    $0x2b,%al
c0107001:	75 06                	jne    c0107009 <strtol+0x3e>
        s ++;
c0107003:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107007:	eb 15                	jmp    c010701e <strtol+0x53>
    }
    else if (*s == '-') {
c0107009:	8b 45 08             	mov    0x8(%ebp),%eax
c010700c:	0f b6 00             	movzbl (%eax),%eax
c010700f:	3c 2d                	cmp    $0x2d,%al
c0107011:	75 0b                	jne    c010701e <strtol+0x53>
        s ++, neg = 1;
c0107013:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107017:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010701e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107022:	74 06                	je     c010702a <strtol+0x5f>
c0107024:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0107028:	75 24                	jne    c010704e <strtol+0x83>
c010702a:	8b 45 08             	mov    0x8(%ebp),%eax
c010702d:	0f b6 00             	movzbl (%eax),%eax
c0107030:	3c 30                	cmp    $0x30,%al
c0107032:	75 1a                	jne    c010704e <strtol+0x83>
c0107034:	8b 45 08             	mov    0x8(%ebp),%eax
c0107037:	83 c0 01             	add    $0x1,%eax
c010703a:	0f b6 00             	movzbl (%eax),%eax
c010703d:	3c 78                	cmp    $0x78,%al
c010703f:	75 0d                	jne    c010704e <strtol+0x83>
        s += 2, base = 16;
c0107041:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0107045:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010704c:	eb 2a                	jmp    c0107078 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010704e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107052:	75 17                	jne    c010706b <strtol+0xa0>
c0107054:	8b 45 08             	mov    0x8(%ebp),%eax
c0107057:	0f b6 00             	movzbl (%eax),%eax
c010705a:	3c 30                	cmp    $0x30,%al
c010705c:	75 0d                	jne    c010706b <strtol+0xa0>
        s ++, base = 8;
c010705e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0107062:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0107069:	eb 0d                	jmp    c0107078 <strtol+0xad>
    }
    else if (base == 0) {
c010706b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010706f:	75 07                	jne    c0107078 <strtol+0xad>
        base = 10;
c0107071:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0107078:	8b 45 08             	mov    0x8(%ebp),%eax
c010707b:	0f b6 00             	movzbl (%eax),%eax
c010707e:	3c 2f                	cmp    $0x2f,%al
c0107080:	7e 1b                	jle    c010709d <strtol+0xd2>
c0107082:	8b 45 08             	mov    0x8(%ebp),%eax
c0107085:	0f b6 00             	movzbl (%eax),%eax
c0107088:	3c 39                	cmp    $0x39,%al
c010708a:	7f 11                	jg     c010709d <strtol+0xd2>
            dig = *s - '0';
c010708c:	8b 45 08             	mov    0x8(%ebp),%eax
c010708f:	0f b6 00             	movzbl (%eax),%eax
c0107092:	0f be c0             	movsbl %al,%eax
c0107095:	83 e8 30             	sub    $0x30,%eax
c0107098:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010709b:	eb 48                	jmp    c01070e5 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010709d:	8b 45 08             	mov    0x8(%ebp),%eax
c01070a0:	0f b6 00             	movzbl (%eax),%eax
c01070a3:	3c 60                	cmp    $0x60,%al
c01070a5:	7e 1b                	jle    c01070c2 <strtol+0xf7>
c01070a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01070aa:	0f b6 00             	movzbl (%eax),%eax
c01070ad:	3c 7a                	cmp    $0x7a,%al
c01070af:	7f 11                	jg     c01070c2 <strtol+0xf7>
            dig = *s - 'a' + 10;
c01070b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01070b4:	0f b6 00             	movzbl (%eax),%eax
c01070b7:	0f be c0             	movsbl %al,%eax
c01070ba:	83 e8 57             	sub    $0x57,%eax
c01070bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01070c0:	eb 23                	jmp    c01070e5 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01070c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01070c5:	0f b6 00             	movzbl (%eax),%eax
c01070c8:	3c 40                	cmp    $0x40,%al
c01070ca:	7e 3d                	jle    c0107109 <strtol+0x13e>
c01070cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01070cf:	0f b6 00             	movzbl (%eax),%eax
c01070d2:	3c 5a                	cmp    $0x5a,%al
c01070d4:	7f 33                	jg     c0107109 <strtol+0x13e>
            dig = *s - 'A' + 10;
c01070d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01070d9:	0f b6 00             	movzbl (%eax),%eax
c01070dc:	0f be c0             	movsbl %al,%eax
c01070df:	83 e8 37             	sub    $0x37,%eax
c01070e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01070e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070e8:	3b 45 10             	cmp    0x10(%ebp),%eax
c01070eb:	7c 02                	jl     c01070ef <strtol+0x124>
            break;
c01070ed:	eb 1a                	jmp    c0107109 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c01070ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01070f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01070f6:	0f af 45 10          	imul   0x10(%ebp),%eax
c01070fa:	89 c2                	mov    %eax,%edx
c01070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070ff:	01 d0                	add    %edx,%eax
c0107101:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0107104:	e9 6f ff ff ff       	jmp    c0107078 <strtol+0xad>

    if (endptr) {
c0107109:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010710d:	74 08                	je     c0107117 <strtol+0x14c>
        *endptr = (char *) s;
c010710f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107112:	8b 55 08             	mov    0x8(%ebp),%edx
c0107115:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0107117:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010711b:	74 07                	je     c0107124 <strtol+0x159>
c010711d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107120:	f7 d8                	neg    %eax
c0107122:	eb 03                	jmp    c0107127 <strtol+0x15c>
c0107124:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0107127:	c9                   	leave  
c0107128:	c3                   	ret    

c0107129 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0107129:	55                   	push   %ebp
c010712a:	89 e5                	mov    %esp,%ebp
c010712c:	57                   	push   %edi
c010712d:	83 ec 24             	sub    $0x24,%esp
c0107130:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107133:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0107136:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010713a:	8b 55 08             	mov    0x8(%ebp),%edx
c010713d:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0107140:	88 45 f7             	mov    %al,-0x9(%ebp)
c0107143:	8b 45 10             	mov    0x10(%ebp),%eax
c0107146:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0107149:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010714c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0107150:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0107153:	89 d7                	mov    %edx,%edi
c0107155:	f3 aa                	rep stos %al,%es:(%edi)
c0107157:	89 fa                	mov    %edi,%edx
c0107159:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010715c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010715f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0107162:	83 c4 24             	add    $0x24,%esp
c0107165:	5f                   	pop    %edi
c0107166:	5d                   	pop    %ebp
c0107167:	c3                   	ret    

c0107168 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0107168:	55                   	push   %ebp
c0107169:	89 e5                	mov    %esp,%ebp
c010716b:	57                   	push   %edi
c010716c:	56                   	push   %esi
c010716d:	53                   	push   %ebx
c010716e:	83 ec 30             	sub    $0x30,%esp
c0107171:	8b 45 08             	mov    0x8(%ebp),%eax
c0107174:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107177:	8b 45 0c             	mov    0xc(%ebp),%eax
c010717a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010717d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107180:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0107183:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107186:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107189:	73 42                	jae    c01071cd <memmove+0x65>
c010718b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010718e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107191:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107194:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107197:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010719a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010719d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071a0:	c1 e8 02             	shr    $0x2,%eax
c01071a3:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01071a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01071a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071ab:	89 d7                	mov    %edx,%edi
c01071ad:	89 c6                	mov    %eax,%esi
c01071af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01071b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01071b4:	83 e1 03             	and    $0x3,%ecx
c01071b7:	74 02                	je     c01071bb <memmove+0x53>
c01071b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01071bb:	89 f0                	mov    %esi,%eax
c01071bd:	89 fa                	mov    %edi,%edx
c01071bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01071c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01071c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01071c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071cb:	eb 36                	jmp    c0107203 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01071cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01071d0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01071d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071d6:	01 c2                	add    %eax,%edx
c01071d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01071db:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01071de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01071e1:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c01071e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01071e7:	89 c1                	mov    %eax,%ecx
c01071e9:	89 d8                	mov    %ebx,%eax
c01071eb:	89 d6                	mov    %edx,%esi
c01071ed:	89 c7                	mov    %eax,%edi
c01071ef:	fd                   	std    
c01071f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01071f2:	fc                   	cld    
c01071f3:	89 f8                	mov    %edi,%eax
c01071f5:	89 f2                	mov    %esi,%edx
c01071f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01071fa:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01071fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0107200:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0107203:	83 c4 30             	add    $0x30,%esp
c0107206:	5b                   	pop    %ebx
c0107207:	5e                   	pop    %esi
c0107208:	5f                   	pop    %edi
c0107209:	5d                   	pop    %ebp
c010720a:	c3                   	ret    

c010720b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010720b:	55                   	push   %ebp
c010720c:	89 e5                	mov    %esp,%ebp
c010720e:	57                   	push   %edi
c010720f:	56                   	push   %esi
c0107210:	83 ec 20             	sub    $0x20,%esp
c0107213:	8b 45 08             	mov    0x8(%ebp),%eax
c0107216:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107219:	8b 45 0c             	mov    0xc(%ebp),%eax
c010721c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010721f:	8b 45 10             	mov    0x10(%ebp),%eax
c0107222:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0107225:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107228:	c1 e8 02             	shr    $0x2,%eax
c010722b:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010722d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107230:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107233:	89 d7                	mov    %edx,%edi
c0107235:	89 c6                	mov    %eax,%esi
c0107237:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0107239:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010723c:	83 e1 03             	and    $0x3,%ecx
c010723f:	74 02                	je     c0107243 <memcpy+0x38>
c0107241:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0107243:	89 f0                	mov    %esi,%eax
c0107245:	89 fa                	mov    %edi,%edx
c0107247:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010724a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010724d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0107250:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0107253:	83 c4 20             	add    $0x20,%esp
c0107256:	5e                   	pop    %esi
c0107257:	5f                   	pop    %edi
c0107258:	5d                   	pop    %ebp
c0107259:	c3                   	ret    

c010725a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010725a:	55                   	push   %ebp
c010725b:	89 e5                	mov    %esp,%ebp
c010725d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0107260:	8b 45 08             	mov    0x8(%ebp),%eax
c0107263:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0107266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107269:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010726c:	eb 30                	jmp    c010729e <memcmp+0x44>
        if (*s1 != *s2) {
c010726e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107271:	0f b6 10             	movzbl (%eax),%edx
c0107274:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107277:	0f b6 00             	movzbl (%eax),%eax
c010727a:	38 c2                	cmp    %al,%dl
c010727c:	74 18                	je     c0107296 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010727e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107281:	0f b6 00             	movzbl (%eax),%eax
c0107284:	0f b6 d0             	movzbl %al,%edx
c0107287:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010728a:	0f b6 00             	movzbl (%eax),%eax
c010728d:	0f b6 c0             	movzbl %al,%eax
c0107290:	29 c2                	sub    %eax,%edx
c0107292:	89 d0                	mov    %edx,%eax
c0107294:	eb 1a                	jmp    c01072b0 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0107296:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010729a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010729e:	8b 45 10             	mov    0x10(%ebp),%eax
c01072a1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01072a4:	89 55 10             	mov    %edx,0x10(%ebp)
c01072a7:	85 c0                	test   %eax,%eax
c01072a9:	75 c3                	jne    c010726e <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c01072ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01072b0:	c9                   	leave  
c01072b1:	c3                   	ret    
