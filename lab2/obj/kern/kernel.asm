
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
// lab 2 added.
#include <kern/pmap.h>
#include <kern/kclock.h>
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 92 01 00 00       	call   f01001e0 <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 82 01 00    	add    $0x182ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 98 be fe ff    	lea    -0x14168(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 6b 30 00 00       	call   f01030d2 <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 b4 be fe ff    	lea    -0x1414c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 45 30 00 00       	call   f01030d2 <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 37 08 00 00       	call   f01008dc <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	56                   	push   %esi
f01000b2:	53                   	push   %ebx
f01000b3:	e8 28 01 00 00       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01000b8:	81 c3 50 82 01 00    	add    $0x18250,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000be:	83 ec 04             	sub    $0x4,%esp
f01000c1:	c7 c2 60 a0 11 f0    	mov    $0xf011a060,%edx
f01000c7:	c7 c0 a0 a6 11 f0    	mov    $0xf011a6a0,%eax
f01000cd:	29 d0                	sub    %edx,%eax
f01000cf:	50                   	push   %eax
f01000d0:	6a 00                	push   $0x0
f01000d2:	52                   	push   %edx
f01000d3:	e8 5f 3c 00 00       	call   f0103d37 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d8:	e8 5e 05 00 00       	call   f010063b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dd:	83 c4 08             	add    $0x8,%esp
f01000e0:	68 ac 1a 00 00       	push   $0x1aac
f01000e5:	8d b3 cf be fe ff    	lea    -0x14131(%ebx),%esi
f01000eb:	56                   	push   %esi
f01000ec:	e8 e1 2f 00 00       	call   f01030d2 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f8:	e8 43 ff ff ff       	call   f0100040 <test_backtrace>
	//test added
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000fd:	83 c4 08             	add    $0x8,%esp
f0100100:	68 ac 1a 00 00       	push   $0x1aac
f0100105:	56                   	push   %esi
f0100106:	e8 c7 2f 00 00       	call   f01030d2 <cprintf>
	// Drop into the kernel monitor.
	mem_init();
f010010b:	e8 81 13 00 00       	call   f0101491 <mem_init>
f0100110:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0100113:	83 ec 0c             	sub    $0xc,%esp
f0100116:	6a 00                	push   $0x0
f0100118:	e8 65 08 00 00       	call   f0100982 <monitor>
f010011d:	83 c4 10             	add    $0x10,%esp
f0100120:	eb f1                	jmp    f0100113 <i386_init+0x69>

f0100122 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100122:	f3 0f 1e fb          	endbr32 
f0100126:	55                   	push   %ebp
f0100127:	89 e5                	mov    %esp,%ebp
f0100129:	57                   	push   %edi
f010012a:	56                   	push   %esi
f010012b:	53                   	push   %ebx
f010012c:	83 ec 0c             	sub    $0xc,%esp
f010012f:	e8 ac 00 00 00       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0100134:	81 c3 d4 81 01 00    	add    $0x181d4,%ebx
f010013a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010013d:	c7 c0 a4 a6 11 f0    	mov    $0xf011a6a4,%eax
f0100143:	83 38 00             	cmpl   $0x0,(%eax)
f0100146:	74 0f                	je     f0100157 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100148:	83 ec 0c             	sub    $0xc,%esp
f010014b:	6a 00                	push   $0x0
f010014d:	e8 30 08 00 00       	call   f0100982 <monitor>
f0100152:	83 c4 10             	add    $0x10,%esp
f0100155:	eb f1                	jmp    f0100148 <_panic+0x26>
	panicstr = fmt;
f0100157:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100159:	fa                   	cli    
f010015a:	fc                   	cld    
	va_start(ap, fmt);
f010015b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010015e:	83 ec 04             	sub    $0x4,%esp
f0100161:	ff 75 0c             	pushl  0xc(%ebp)
f0100164:	ff 75 08             	pushl  0x8(%ebp)
f0100167:	8d 83 ea be fe ff    	lea    -0x14116(%ebx),%eax
f010016d:	50                   	push   %eax
f010016e:	e8 5f 2f 00 00       	call   f01030d2 <cprintf>
	vcprintf(fmt, ap);
f0100173:	83 c4 08             	add    $0x8,%esp
f0100176:	56                   	push   %esi
f0100177:	57                   	push   %edi
f0100178:	e8 1a 2f 00 00       	call   f0103097 <vcprintf>
	cprintf("\n");
f010017d:	8d 83 71 ce fe ff    	lea    -0x1318f(%ebx),%eax
f0100183:	89 04 24             	mov    %eax,(%esp)
f0100186:	e8 47 2f 00 00       	call   f01030d2 <cprintf>
f010018b:	83 c4 10             	add    $0x10,%esp
f010018e:	eb b8                	jmp    f0100148 <_panic+0x26>

f0100190 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100190:	f3 0f 1e fb          	endbr32 
f0100194:	55                   	push   %ebp
f0100195:	89 e5                	mov    %esp,%ebp
f0100197:	56                   	push   %esi
f0100198:	53                   	push   %ebx
f0100199:	e8 42 00 00 00       	call   f01001e0 <__x86.get_pc_thunk.bx>
f010019e:	81 c3 6a 81 01 00    	add    $0x1816a,%ebx
	va_list ap;

	va_start(ap, fmt);
f01001a4:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001a7:	83 ec 04             	sub    $0x4,%esp
f01001aa:	ff 75 0c             	pushl  0xc(%ebp)
f01001ad:	ff 75 08             	pushl  0x8(%ebp)
f01001b0:	8d 83 02 bf fe ff    	lea    -0x140fe(%ebx),%eax
f01001b6:	50                   	push   %eax
f01001b7:	e8 16 2f 00 00       	call   f01030d2 <cprintf>
	vcprintf(fmt, ap);
f01001bc:	83 c4 08             	add    $0x8,%esp
f01001bf:	56                   	push   %esi
f01001c0:	ff 75 10             	pushl  0x10(%ebp)
f01001c3:	e8 cf 2e 00 00       	call   f0103097 <vcprintf>
	cprintf("\n");
f01001c8:	8d 83 71 ce fe ff    	lea    -0x1318f(%ebx),%eax
f01001ce:	89 04 24             	mov    %eax,(%esp)
f01001d1:	e8 fc 2e 00 00       	call   f01030d2 <cprintf>
	va_end(ap);
}
f01001d6:	83 c4 10             	add    $0x10,%esp
f01001d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001dc:	5b                   	pop    %ebx
f01001dd:	5e                   	pop    %esi
f01001de:	5d                   	pop    %ebp
f01001df:	c3                   	ret    

f01001e0 <__x86.get_pc_thunk.bx>:
f01001e0:	8b 1c 24             	mov    (%esp),%ebx
f01001e3:	c3                   	ret    

f01001e4 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001e4:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001ed:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ee:	a8 01                	test   $0x1,%al
f01001f0:	74 0a                	je     f01001fc <serial_proc_data+0x18>
f01001f2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f7:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001f8:	0f b6 c0             	movzbl %al,%eax
f01001fb:	c3                   	ret    
		return -1;
f01001fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100201:	c3                   	ret    

f0100202 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100202:	55                   	push   %ebp
f0100203:	89 e5                	mov    %esp,%ebp
f0100205:	57                   	push   %edi
f0100206:	56                   	push   %esi
f0100207:	53                   	push   %ebx
f0100208:	83 ec 1c             	sub    $0x1c,%esp
f010020b:	e8 88 05 00 00       	call   f0100798 <__x86.get_pc_thunk.si>
f0100210:	81 c6 f8 80 01 00    	add    $0x180f8,%esi
f0100216:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100218:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010021e:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0100221:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100224:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010022a:	ff d0                	call   *%eax
f010022c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022f:	74 2b                	je     f010025c <cons_intr+0x5a>
		if (c == 0)
f0100231:	85 c0                	test   %eax,%eax
f0100233:	74 f2                	je     f0100227 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100235:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010023c:	8d 51 01             	lea    0x1(%ecx),%edx
f010023f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100242:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100245:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010024b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100250:	0f 44 d0             	cmove  %eax,%edx
f0100253:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f010025a:	eb cb                	jmp    f0100227 <cons_intr+0x25>
	}
}
f010025c:	83 c4 1c             	add    $0x1c,%esp
f010025f:	5b                   	pop    %ebx
f0100260:	5e                   	pop    %esi
f0100261:	5f                   	pop    %edi
f0100262:	5d                   	pop    %ebp
f0100263:	c3                   	ret    

f0100264 <kbd_proc_data>:
{
f0100264:	f3 0f 1e fb          	endbr32 
f0100268:	55                   	push   %ebp
f0100269:	89 e5                	mov    %esp,%ebp
f010026b:	56                   	push   %esi
f010026c:	53                   	push   %ebx
f010026d:	e8 6e ff ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0100272:	81 c3 96 80 01 00    	add    $0x18096,%ebx
f0100278:	ba 64 00 00 00       	mov    $0x64,%edx
f010027d:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010027e:	a8 01                	test   $0x1,%al
f0100280:	0f 84 fb 00 00 00    	je     f0100381 <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100286:	a8 20                	test   $0x20,%al
f0100288:	0f 85 fa 00 00 00    	jne    f0100388 <kbd_proc_data+0x124>
f010028e:	ba 60 00 00 00       	mov    $0x60,%edx
f0100293:	ec                   	in     (%dx),%al
f0100294:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100296:	3c e0                	cmp    $0xe0,%al
f0100298:	74 64                	je     f01002fe <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f010029a:	84 c0                	test   %al,%al
f010029c:	78 75                	js     f0100313 <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010029e:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01002a4:	f6 c1 40             	test   $0x40,%cl
f01002a7:	74 0e                	je     f01002b7 <kbd_proc_data+0x53>
		data |= 0x80;
f01002a9:	83 c8 80             	or     $0xffffff80,%eax
f01002ac:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ae:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002b1:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002b7:	0f b6 d2             	movzbl %dl,%edx
f01002ba:	0f b6 84 13 58 c0 fe 	movzbl -0x13fa8(%ebx,%edx,1),%eax
f01002c1:	ff 
f01002c2:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002c8:	0f b6 8c 13 58 bf fe 	movzbl -0x140a8(%ebx,%edx,1),%ecx
f01002cf:	ff 
f01002d0:	31 c8                	xor    %ecx,%eax
f01002d2:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002d8:	89 c1                	mov    %eax,%ecx
f01002da:	83 e1 03             	and    $0x3,%ecx
f01002dd:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002e4:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002e8:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002eb:	a8 08                	test   $0x8,%al
f01002ed:	74 65                	je     f0100354 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002ef:	89 f2                	mov    %esi,%edx
f01002f1:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002f4:	83 f9 19             	cmp    $0x19,%ecx
f01002f7:	77 4f                	ja     f0100348 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002f9:	83 ee 20             	sub    $0x20,%esi
f01002fc:	eb 0c                	jmp    f010030a <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002fe:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f0100305:	be 00 00 00 00       	mov    $0x0,%esi
}
f010030a:	89 f0                	mov    %esi,%eax
f010030c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010030f:	5b                   	pop    %ebx
f0100310:	5e                   	pop    %esi
f0100311:	5d                   	pop    %ebp
f0100312:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100313:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100319:	89 ce                	mov    %ecx,%esi
f010031b:	83 e6 40             	and    $0x40,%esi
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 f6                	test   %esi,%esi
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 84 13 58 c0 fe 	movzbl -0x13fa8(%ebx,%edx,1),%eax
f0100330:	ff 
f0100331:	83 c8 40             	or     $0x40,%eax
f0100334:	0f b6 c0             	movzbl %al,%eax
f0100337:	f7 d0                	not    %eax
f0100339:	21 c8                	and    %ecx,%eax
f010033b:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100341:	be 00 00 00 00       	mov    $0x0,%esi
f0100346:	eb c2                	jmp    f010030a <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100348:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010034b:	8d 4e 20             	lea    0x20(%esi),%ecx
f010034e:	83 fa 1a             	cmp    $0x1a,%edx
f0100351:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100354:	f7 d0                	not    %eax
f0100356:	a8 06                	test   $0x6,%al
f0100358:	75 b0                	jne    f010030a <kbd_proc_data+0xa6>
f010035a:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100360:	75 a8                	jne    f010030a <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f0100362:	83 ec 0c             	sub    $0xc,%esp
f0100365:	8d 83 1c bf fe ff    	lea    -0x140e4(%ebx),%eax
f010036b:	50                   	push   %eax
f010036c:	e8 61 2d 00 00       	call   f01030d2 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100371:	b8 03 00 00 00       	mov    $0x3,%eax
f0100376:	ba 92 00 00 00       	mov    $0x92,%edx
f010037b:	ee                   	out    %al,(%dx)
}
f010037c:	83 c4 10             	add    $0x10,%esp
f010037f:	eb 89                	jmp    f010030a <kbd_proc_data+0xa6>
		return -1;
f0100381:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100386:	eb 82                	jmp    f010030a <kbd_proc_data+0xa6>
		return -1;
f0100388:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010038d:	e9 78 ff ff ff       	jmp    f010030a <kbd_proc_data+0xa6>

f0100392 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100392:	55                   	push   %ebp
f0100393:	89 e5                	mov    %esp,%ebp
f0100395:	57                   	push   %edi
f0100396:	56                   	push   %esi
f0100397:	53                   	push   %ebx
f0100398:	83 ec 1c             	sub    $0x1c,%esp
f010039b:	e8 40 fe ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01003a0:	81 c3 68 7f 01 00    	add    $0x17f68,%ebx
f01003a6:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003a8:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ad:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003b7:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003b8:	a8 20                	test   $0x20,%al
f01003ba:	75 13                	jne    f01003cf <cons_putc+0x3d>
f01003bc:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c2:	7f 0b                	jg     f01003cf <cons_putc+0x3d>
f01003c4:	89 ca                	mov    %ecx,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	ec                   	in     (%dx),%al
f01003c8:	ec                   	in     (%dx),%al
f01003c9:	ec                   	in     (%dx),%al
	     i++)
f01003ca:	83 c6 01             	add    $0x1,%esi
f01003cd:	eb e3                	jmp    f01003b2 <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003cf:	89 f8                	mov    %edi,%eax
f01003d1:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003da:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003df:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e4:	ba 79 03 00 00       	mov    $0x379,%edx
f01003e9:	ec                   	in     (%dx),%al
f01003ea:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003f0:	7f 0f                	jg     f0100401 <cons_putc+0x6f>
f01003f2:	84 c0                	test   %al,%al
f01003f4:	78 0b                	js     f0100401 <cons_putc+0x6f>
f01003f6:	89 ca                	mov    %ecx,%edx
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
f01003fc:	83 c6 01             	add    $0x1,%esi
f01003ff:	eb e3                	jmp    f01003e4 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100401:	ba 78 03 00 00       	mov    $0x378,%edx
f0100406:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010040a:	ee                   	out    %al,(%dx)
f010040b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100410:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100415:	ee                   	out    %al,(%dx)
f0100416:	b8 08 00 00 00       	mov    $0x8,%eax
f010041b:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010041c:	89 f8                	mov    %edi,%eax
f010041e:	80 cc 07             	or     $0x7,%ah
f0100421:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100427:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010042a:	89 f8                	mov    %edi,%eax
f010042c:	0f b6 c0             	movzbl %al,%eax
f010042f:	89 f9                	mov    %edi,%ecx
f0100431:	80 f9 0a             	cmp    $0xa,%cl
f0100434:	0f 84 e2 00 00 00    	je     f010051c <cons_putc+0x18a>
f010043a:	83 f8 0a             	cmp    $0xa,%eax
f010043d:	7f 46                	jg     f0100485 <cons_putc+0xf3>
f010043f:	83 f8 08             	cmp    $0x8,%eax
f0100442:	0f 84 a8 00 00 00    	je     f01004f0 <cons_putc+0x15e>
f0100448:	83 f8 09             	cmp    $0x9,%eax
f010044b:	0f 85 d8 00 00 00    	jne    f0100529 <cons_putc+0x197>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 37 ff ff ff       	call   f0100392 <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 2d ff ff ff       	call   f0100392 <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 23 ff ff ff       	call   f0100392 <cons_putc>
		cons_putc(' ');
f010046f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100474:	e8 19 ff ff ff       	call   f0100392 <cons_putc>
		cons_putc(' ');
f0100479:	b8 20 00 00 00       	mov    $0x20,%eax
f010047e:	e8 0f ff ff ff       	call   f0100392 <cons_putc>
		break;
f0100483:	eb 26                	jmp    f01004ab <cons_putc+0x119>
	switch (c & 0xff) {
f0100485:	83 f8 0d             	cmp    $0xd,%eax
f0100488:	0f 85 9b 00 00 00    	jne    f0100529 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010048e:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100495:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010049b:	c1 e8 16             	shr    $0x16,%eax
f010049e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004a1:	c1 e0 04             	shl    $0x4,%eax
f01004a4:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004ab:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f01004b2:	cf 07 
f01004b4:	0f 87 92 00 00 00    	ja     f010054c <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004ba:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004c0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c5:	89 ca                	mov    %ecx,%edx
f01004c7:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c8:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004cf:	8d 71 01             	lea    0x1(%ecx),%esi
f01004d2:	89 d8                	mov    %ebx,%eax
f01004d4:	66 c1 e8 08          	shr    $0x8,%ax
f01004d8:	89 f2                	mov    %esi,%edx
f01004da:	ee                   	out    %al,(%dx)
f01004db:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e0:	89 ca                	mov    %ecx,%edx
f01004e2:	ee                   	out    %al,(%dx)
f01004e3:	89 d8                	mov    %ebx,%eax
f01004e5:	89 f2                	mov    %esi,%edx
f01004e7:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004eb:	5b                   	pop    %ebx
f01004ec:	5e                   	pop    %esi
f01004ed:	5f                   	pop    %edi
f01004ee:	5d                   	pop    %ebp
f01004ef:	c3                   	ret    
		if (crt_pos > 0) {
f01004f0:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004f7:	66 85 c0             	test   %ax,%ax
f01004fa:	74 be                	je     f01004ba <cons_putc+0x128>
			crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100506:	0f b7 c0             	movzwl %ax,%eax
f0100509:	89 fa                	mov    %edi,%edx
f010050b:	b2 00                	mov    $0x0,%dl
f010050d:	83 ca 20             	or     $0x20,%edx
f0100510:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100516:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010051a:	eb 8f                	jmp    f01004ab <cons_putc+0x119>
		crt_pos += CRT_COLS;
f010051c:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f0100523:	50 
f0100524:	e9 65 ff ff ff       	jmp    f010048e <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100529:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100530:	8d 50 01             	lea    0x1(%eax),%edx
f0100533:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f010053a:	0f b7 c0             	movzwl %ax,%eax
f010053d:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100543:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100547:	e9 5f ff ff ff       	jmp    f01004ab <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054c:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f0100552:	83 ec 04             	sub    $0x4,%esp
f0100555:	68 00 0f 00 00       	push   $0xf00
f010055a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100560:	52                   	push   %edx
f0100561:	50                   	push   %eax
f0100562:	e8 1c 38 00 00       	call   f0103d83 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100567:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010056d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100573:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100579:	83 c4 10             	add    $0x10,%esp
f010057c:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100581:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100584:	39 d0                	cmp    %edx,%eax
f0100586:	75 f4                	jne    f010057c <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100588:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010058f:	50 
f0100590:	e9 25 ff ff ff       	jmp    f01004ba <cons_putc+0x128>

f0100595 <serial_intr>:
{
f0100595:	f3 0f 1e fb          	endbr32 
f0100599:	e8 f6 01 00 00       	call   f0100794 <__x86.get_pc_thunk.ax>
f010059e:	05 6a 7d 01 00       	add    $0x17d6a,%eax
	if (serial_exists)
f01005a3:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f01005aa:	75 01                	jne    f01005ad <serial_intr+0x18>
f01005ac:	c3                   	ret    
{
f01005ad:	55                   	push   %ebp
f01005ae:	89 e5                	mov    %esp,%ebp
f01005b0:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005b3:	8d 80 dc 7e fe ff    	lea    -0x18124(%eax),%eax
f01005b9:	e8 44 fc ff ff       	call   f0100202 <cons_intr>
}
f01005be:	c9                   	leave  
f01005bf:	c3                   	ret    

f01005c0 <kbd_intr>:
{
f01005c0:	f3 0f 1e fb          	endbr32 
f01005c4:	55                   	push   %ebp
f01005c5:	89 e5                	mov    %esp,%ebp
f01005c7:	83 ec 08             	sub    $0x8,%esp
f01005ca:	e8 c5 01 00 00       	call   f0100794 <__x86.get_pc_thunk.ax>
f01005cf:	05 39 7d 01 00       	add    $0x17d39,%eax
	cons_intr(kbd_proc_data);
f01005d4:	8d 80 5c 7f fe ff    	lea    -0x180a4(%eax),%eax
f01005da:	e8 23 fc ff ff       	call   f0100202 <cons_intr>
}
f01005df:	c9                   	leave  
f01005e0:	c3                   	ret    

f01005e1 <cons_getc>:
{
f01005e1:	f3 0f 1e fb          	endbr32 
f01005e5:	55                   	push   %ebp
f01005e6:	89 e5                	mov    %esp,%ebp
f01005e8:	53                   	push   %ebx
f01005e9:	83 ec 04             	sub    $0x4,%esp
f01005ec:	e8 ef fb ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01005f1:	81 c3 17 7d 01 00    	add    $0x17d17,%ebx
	serial_intr();
f01005f7:	e8 99 ff ff ff       	call   f0100595 <serial_intr>
	kbd_intr();
f01005fc:	e8 bf ff ff ff       	call   f01005c0 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100601:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f0100607:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010060c:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f0100612:	74 1f                	je     f0100633 <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100614:	8d 48 01             	lea    0x1(%eax),%ecx
f0100617:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010061e:	00 
			cons.rpos = 0;
f010061f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100625:	b8 00 00 00 00       	mov    $0x0,%eax
f010062a:	0f 44 c8             	cmove  %eax,%ecx
f010062d:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f0100633:	89 d0                	mov    %edx,%eax
f0100635:	83 c4 04             	add    $0x4,%esp
f0100638:	5b                   	pop    %ebx
f0100639:	5d                   	pop    %ebp
f010063a:	c3                   	ret    

f010063b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010063b:	f3 0f 1e fb          	endbr32 
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	57                   	push   %edi
f0100643:	56                   	push   %esi
f0100644:	53                   	push   %ebx
f0100645:	83 ec 1c             	sub    $0x1c,%esp
f0100648:	e8 93 fb ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f010064d:	81 c3 bb 7c 01 00    	add    $0x17cbb,%ebx
	was = *cp;
f0100653:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010065a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100661:	5a a5 
	if (*cp != 0xA55A) {
f0100663:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010066a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066e:	0f 84 bc 00 00 00    	je     f0100730 <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100674:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010067b:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067e:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100685:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010068b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100693:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100696:	89 ca                	mov    %ecx,%edx
f0100698:	ec                   	in     (%dx),%al
f0100699:	0f b6 f0             	movzbl %al,%esi
f010069c:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069f:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a4:	89 fa                	mov    %edi,%edx
f01006a6:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a7:	89 ca                	mov    %ecx,%edx
f01006a9:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01006ad:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f01006b3:	0f b6 c0             	movzbl %al,%eax
f01006b6:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006b8:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006c4:	89 c8                	mov    %ecx,%eax
f01006c6:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006cb:	ee                   	out    %al,(%dx)
f01006cc:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006d1:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006d6:	89 fa                	mov    %edi,%edx
f01006d8:	ee                   	out    %al,(%dx)
f01006d9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e3:	ee                   	out    %al,(%dx)
f01006e4:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006e9:	89 c8                	mov    %ecx,%eax
f01006eb:	89 f2                	mov    %esi,%edx
f01006ed:	ee                   	out    %al,(%dx)
f01006ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f3:	89 fa                	mov    %edi,%edx
f01006f5:	ee                   	out    %al,(%dx)
f01006f6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006fb:	89 c8                	mov    %ecx,%eax
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0100703:	89 f2                	mov    %esi,%edx
f0100705:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100706:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010070b:	ec                   	in     (%dx),%al
f010070c:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010070e:	3c ff                	cmp    $0xff,%al
f0100710:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100717:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010071c:	ec                   	in     (%dx),%al
f010071d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100722:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100723:	80 f9 ff             	cmp    $0xff,%cl
f0100726:	74 25                	je     f010074d <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100728:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010072b:	5b                   	pop    %ebx
f010072c:	5e                   	pop    %esi
f010072d:	5f                   	pop    %edi
f010072e:	5d                   	pop    %ebp
f010072f:	c3                   	ret    
		*cp = was;
f0100730:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100737:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010073e:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100741:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100748:	e9 38 ff ff ff       	jmp    f0100685 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f010074d:	83 ec 0c             	sub    $0xc,%esp
f0100750:	8d 83 28 bf fe ff    	lea    -0x140d8(%ebx),%eax
f0100756:	50                   	push   %eax
f0100757:	e8 76 29 00 00       	call   f01030d2 <cprintf>
f010075c:	83 c4 10             	add    $0x10,%esp
}
f010075f:	eb c7                	jmp    f0100728 <cons_init+0xed>

f0100761 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076b:	8b 45 08             	mov    0x8(%ebp),%eax
f010076e:	e8 1f fc ff ff       	call   f0100392 <cons_putc>
}
f0100773:	c9                   	leave  
f0100774:	c3                   	ret    

f0100775 <getchar>:

int
getchar(void)
{
f0100775:	f3 0f 1e fb          	endbr32 
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077f:	e8 5d fe ff ff       	call   f01005e1 <cons_getc>
f0100784:	85 c0                	test   %eax,%eax
f0100786:	74 f7                	je     f010077f <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <iscons>:

int
iscons(int fdnum)
{
f010078a:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010078e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100793:	c3                   	ret    

f0100794 <__x86.get_pc_thunk.ax>:
f0100794:	8b 04 24             	mov    (%esp),%eax
f0100797:	c3                   	ret    

f0100798 <__x86.get_pc_thunk.si>:
f0100798:	8b 34 24             	mov    (%esp),%esi
f010079b:	c3                   	ret    

f010079c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010079c:	f3 0f 1e fb          	endbr32 
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	56                   	push   %esi
f01007a4:	53                   	push   %ebx
f01007a5:	e8 36 fa ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01007aa:	81 c3 5e 7b 01 00    	add    $0x17b5e,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b0:	83 ec 04             	sub    $0x4,%esp
f01007b3:	8d 83 58 c1 fe ff    	lea    -0x13ea8(%ebx),%eax
f01007b9:	50                   	push   %eax
f01007ba:	8d 83 76 c1 fe ff    	lea    -0x13e8a(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	8d b3 7b c1 fe ff    	lea    -0x13e85(%ebx),%esi
f01007c7:	56                   	push   %esi
f01007c8:	e8 05 29 00 00       	call   f01030d2 <cprintf>
f01007cd:	83 c4 0c             	add    $0xc,%esp
f01007d0:	8d 83 28 c2 fe ff    	lea    -0x13dd8(%ebx),%eax
f01007d6:	50                   	push   %eax
f01007d7:	8d 83 84 c1 fe ff    	lea    -0x13e7c(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	56                   	push   %esi
f01007df:	e8 ee 28 00 00       	call   f01030d2 <cprintf>
f01007e4:	83 c4 0c             	add    $0xc,%esp
f01007e7:	8d 83 8d c1 fe ff    	lea    -0x13e73(%ebx),%eax
f01007ed:	50                   	push   %eax
f01007ee:	8d 83 a4 c1 fe ff    	lea    -0x13e5c(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	56                   	push   %esi
f01007f6:	e8 d7 28 00 00       	call   f01030d2 <cprintf>
	return 0;
}
f01007fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100800:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100803:	5b                   	pop    %ebx
f0100804:	5e                   	pop    %esi
f0100805:	5d                   	pop    %ebp
f0100806:	c3                   	ret    

f0100807 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100807:	f3 0f 1e fb          	endbr32 
f010080b:	55                   	push   %ebp
f010080c:	89 e5                	mov    %esp,%ebp
f010080e:	57                   	push   %edi
f010080f:	56                   	push   %esi
f0100810:	53                   	push   %ebx
f0100811:	83 ec 18             	sub    $0x18,%esp
f0100814:	e8 c7 f9 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0100819:	81 c3 ef 7a 01 00    	add    $0x17aef,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010081f:	8d 83 ae c1 fe ff    	lea    -0x13e52(%ebx),%eax
f0100825:	50                   	push   %eax
f0100826:	e8 a7 28 00 00       	call   f01030d2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010082b:	83 c4 08             	add    $0x8,%esp
f010082e:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100834:	8d 83 50 c2 fe ff    	lea    -0x13db0(%ebx),%eax
f010083a:	50                   	push   %eax
f010083b:	e8 92 28 00 00       	call   f01030d2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100840:	83 c4 0c             	add    $0xc,%esp
f0100843:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100849:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010084f:	50                   	push   %eax
f0100850:	57                   	push   %edi
f0100851:	8d 83 78 c2 fe ff    	lea    -0x13d88(%ebx),%eax
f0100857:	50                   	push   %eax
f0100858:	e8 75 28 00 00       	call   f01030d2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010085d:	83 c4 0c             	add    $0xc,%esp
f0100860:	c7 c0 9d 41 10 f0    	mov    $0xf010419d,%eax
f0100866:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010086c:	52                   	push   %edx
f010086d:	50                   	push   %eax
f010086e:	8d 83 9c c2 fe ff    	lea    -0x13d64(%ebx),%eax
f0100874:	50                   	push   %eax
f0100875:	e8 58 28 00 00       	call   f01030d2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	c7 c0 60 a0 11 f0    	mov    $0xf011a060,%eax
f0100883:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100889:	52                   	push   %edx
f010088a:	50                   	push   %eax
f010088b:	8d 83 c0 c2 fe ff    	lea    -0x13d40(%ebx),%eax
f0100891:	50                   	push   %eax
f0100892:	e8 3b 28 00 00       	call   f01030d2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100897:	83 c4 0c             	add    $0xc,%esp
f010089a:	c7 c6 a0 a6 11 f0    	mov    $0xf011a6a0,%esi
f01008a0:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01008a6:	50                   	push   %eax
f01008a7:	56                   	push   %esi
f01008a8:	8d 83 e4 c2 fe ff    	lea    -0x13d1c(%ebx),%eax
f01008ae:	50                   	push   %eax
f01008af:	e8 1e 28 00 00       	call   f01030d2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b4:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b7:	29 fe                	sub    %edi,%esi
f01008b9:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008bf:	c1 fe 0a             	sar    $0xa,%esi
f01008c2:	56                   	push   %esi
f01008c3:	8d 83 08 c3 fe ff    	lea    -0x13cf8(%ebx),%eax
f01008c9:	50                   	push   %eax
f01008ca:	e8 03 28 00 00       	call   f01030d2 <cprintf>
	return 0;
}
f01008cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d7:	5b                   	pop    %ebx
f01008d8:	5e                   	pop    %esi
f01008d9:	5f                   	pop    %edi
f01008da:	5d                   	pop    %ebp
f01008db:	c3                   	ret    

f01008dc <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008dc:	f3 0f 1e fb          	endbr32 
f01008e0:	55                   	push   %ebp
f01008e1:	89 e5                	mov    %esp,%ebp
f01008e3:	57                   	push   %edi
f01008e4:	56                   	push   %esi
f01008e5:	53                   	push   %ebx
f01008e6:	83 ec 48             	sub    $0x48,%esp
f01008e9:	e8 f2 f8 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01008ee:	81 c3 1a 7a 01 00    	add    $0x17a1a,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008f4:	89 ee                	mov    %ebp,%esi
	uint32_t ebp, *p, eip;
	struct Eipdebuginfo info;
    	ebp = read_ebp();
    	cprintf("Stack backtrace:\n");
f01008f6:	8d 83 c7 c1 fe ff    	lea    -0x13e39(%ebx),%eax
f01008fc:	50                   	push   %eax
f01008fd:	e8 d0 27 00 00       	call   f01030d2 <cprintf>
    	while (ebp != 0)
f0100902:	83 c4 10             	add    $0x10,%esp
    	{
        	p = (uint32_t *) ebp;
        	eip = p[1];
        	cprintf("ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, eip, p[2], p[3], p[4], p[5], p[6]);
f0100905:	8d 83 34 c3 fe ff    	lea    -0x13ccc(%ebx),%eax
f010090b:	89 45 c0             	mov    %eax,-0x40(%ebp)
        	if (debuginfo_eip(eip, &info) == 0)
        	{
        		int fn_offset = eip - info.eip_fn_addr;
        		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
f010090e:	8d 83 d9 c1 fe ff    	lea    -0x13e27(%ebx),%eax
f0100914:	89 45 bc             	mov    %eax,-0x44(%ebp)
    	while (ebp != 0)
f0100917:	eb 23                	jmp    f010093c <mon_backtrace+0x60>
        		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
f0100919:	83 ec 08             	sub    $0x8,%esp
        		int fn_offset = eip - info.eip_fn_addr;
f010091c:	2b 7d e0             	sub    -0x20(%ebp),%edi
        		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
f010091f:	57                   	push   %edi
f0100920:	ff 75 d8             	pushl  -0x28(%ebp)
f0100923:	ff 75 dc             	pushl  -0x24(%ebp)
f0100926:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100929:	ff 75 d0             	pushl  -0x30(%ebp)
f010092c:	ff 75 bc             	pushl  -0x44(%ebp)
f010092f:	e8 9e 27 00 00       	call   f01030d2 <cprintf>
f0100934:	83 c4 20             	add    $0x20,%esp
        	}
        	ebp = p[0];
f0100937:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010093a:	8b 30                	mov    (%eax),%esi
    	while (ebp != 0)
f010093c:	85 f6                	test   %esi,%esi
f010093e:	74 35                	je     f0100975 <mon_backtrace+0x99>
        	p = (uint32_t *) ebp;
f0100940:	89 75 c4             	mov    %esi,-0x3c(%ebp)
        	eip = p[1];
f0100943:	8b 7e 04             	mov    0x4(%esi),%edi
        	cprintf("ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, eip, p[2], p[3], p[4], p[5], p[6]);
f0100946:	ff 76 18             	pushl  0x18(%esi)
f0100949:	ff 76 14             	pushl  0x14(%esi)
f010094c:	ff 76 10             	pushl  0x10(%esi)
f010094f:	ff 76 0c             	pushl  0xc(%esi)
f0100952:	ff 76 08             	pushl  0x8(%esi)
f0100955:	57                   	push   %edi
f0100956:	56                   	push   %esi
f0100957:	ff 75 c0             	pushl  -0x40(%ebp)
f010095a:	e8 73 27 00 00       	call   f01030d2 <cprintf>
        	if (debuginfo_eip(eip, &info) == 0)
f010095f:	83 c4 18             	add    $0x18,%esp
f0100962:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100965:	50                   	push   %eax
f0100966:	57                   	push   %edi
f0100967:	e8 73 28 00 00       	call   f01031df <debuginfo_eip>
f010096c:	83 c4 10             	add    $0x10,%esp
f010096f:	85 c0                	test   %eax,%eax
f0100971:	75 c4                	jne    f0100937 <mon_backtrace+0x5b>
f0100973:	eb a4                	jmp    f0100919 <mon_backtrace+0x3d>
    	}
  	return 0;
}
f0100975:	b8 00 00 00 00       	mov    $0x0,%eax
f010097a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010097d:	5b                   	pop    %ebx
f010097e:	5e                   	pop    %esi
f010097f:	5f                   	pop    %edi
f0100980:	5d                   	pop    %ebp
f0100981:	c3                   	ret    

f0100982 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100982:	f3 0f 1e fb          	endbr32 
f0100986:	55                   	push   %ebp
f0100987:	89 e5                	mov    %esp,%ebp
f0100989:	57                   	push   %edi
f010098a:	56                   	push   %esi
f010098b:	53                   	push   %ebx
f010098c:	83 ec 68             	sub    $0x68,%esp
f010098f:	e8 4c f8 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0100994:	81 c3 74 79 01 00    	add    $0x17974,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010099a:	8d 83 64 c3 fe ff    	lea    -0x13c9c(%ebx),%eax
f01009a0:	50                   	push   %eax
f01009a1:	e8 2c 27 00 00       	call   f01030d2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009a6:	8d 83 88 c3 fe ff    	lea    -0x13c78(%ebx),%eax
f01009ac:	89 04 24             	mov    %eax,(%esp)
f01009af:	e8 1e 27 00 00       	call   f01030d2 <cprintf>
f01009b4:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009b7:	8d 83 ed c1 fe ff    	lea    -0x13e13(%ebx),%eax
f01009bd:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01009c0:	e9 d1 00 00 00       	jmp    f0100a96 <monitor+0x114>
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	0f be c0             	movsbl %al,%eax
f01009cb:	50                   	push   %eax
f01009cc:	ff 75 a0             	pushl  -0x60(%ebp)
f01009cf:	e8 1e 33 00 00       	call   f0103cf2 <strchr>
f01009d4:	83 c4 10             	add    $0x10,%esp
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	74 6d                	je     f0100a48 <monitor+0xc6>
			*buf++ = 0;
f01009db:	c6 06 00             	movb   $0x0,(%esi)
f01009de:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01009e1:	8d 76 01             	lea    0x1(%esi),%esi
f01009e4:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f01009e7:	0f b6 06             	movzbl (%esi),%eax
f01009ea:	84 c0                	test   %al,%al
f01009ec:	75 d7                	jne    f01009c5 <monitor+0x43>
	argv[argc] = 0;
f01009ee:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01009f5:	00 
	if (argc == 0)
f01009f6:	85 ff                	test   %edi,%edi
f01009f8:	0f 84 98 00 00 00    	je     f0100a96 <monitor+0x114>
f01009fe:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a09:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a0c:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a0e:	83 ec 08             	sub    $0x8,%esp
f0100a11:	ff 36                	pushl  (%esi)
f0100a13:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a16:	e8 71 32 00 00       	call   f0103c8c <strcmp>
f0100a1b:	83 c4 10             	add    $0x10,%esp
f0100a1e:	85 c0                	test   %eax,%eax
f0100a20:	0f 84 99 00 00 00    	je     f0100abf <monitor+0x13d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a26:	83 c7 01             	add    $0x1,%edi
f0100a29:	83 c6 0c             	add    $0xc,%esi
f0100a2c:	83 ff 03             	cmp    $0x3,%edi
f0100a2f:	75 dd                	jne    f0100a0e <monitor+0x8c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a37:	8d 83 0f c2 fe ff    	lea    -0x13df1(%ebx),%eax
f0100a3d:	50                   	push   %eax
f0100a3e:	e8 8f 26 00 00       	call   f01030d2 <cprintf>
	return 0;
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	eb 4e                	jmp    f0100a96 <monitor+0x114>
		if (*buf == 0)
f0100a48:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a4b:	74 a1                	je     f01009ee <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a4d:	83 ff 0f             	cmp    $0xf,%edi
f0100a50:	74 30                	je     f0100a82 <monitor+0x100>
		argv[argc++] = buf;
f0100a52:	8d 47 01             	lea    0x1(%edi),%eax
f0100a55:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a58:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a5c:	0f b6 06             	movzbl (%esi),%eax
f0100a5f:	84 c0                	test   %al,%al
f0100a61:	74 81                	je     f01009e4 <monitor+0x62>
f0100a63:	83 ec 08             	sub    $0x8,%esp
f0100a66:	0f be c0             	movsbl %al,%eax
f0100a69:	50                   	push   %eax
f0100a6a:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a6d:	e8 80 32 00 00       	call   f0103cf2 <strchr>
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	0f 85 67 ff ff ff    	jne    f01009e4 <monitor+0x62>
			buf++;
f0100a7d:	83 c6 01             	add    $0x1,%esi
f0100a80:	eb da                	jmp    f0100a5c <monitor+0xda>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a82:	83 ec 08             	sub    $0x8,%esp
f0100a85:	6a 10                	push   $0x10
f0100a87:	8d 83 f2 c1 fe ff    	lea    -0x13e0e(%ebx),%eax
f0100a8d:	50                   	push   %eax
f0100a8e:	e8 3f 26 00 00       	call   f01030d2 <cprintf>
			return 0;
f0100a93:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a96:	8d bb e9 c1 fe ff    	lea    -0x13e17(%ebx),%edi
f0100a9c:	83 ec 0c             	sub    $0xc,%esp
f0100a9f:	57                   	push   %edi
f0100aa0:	e8 dc 2f 00 00       	call   f0103a81 <readline>
		if (buf != NULL)
f0100aa5:	83 c4 10             	add    $0x10,%esp
f0100aa8:	85 c0                	test   %eax,%eax
f0100aaa:	74 f0                	je     f0100a9c <monitor+0x11a>
f0100aac:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100aae:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ab5:	bf 00 00 00 00       	mov    $0x0,%edi
f0100aba:	e9 28 ff ff ff       	jmp    f01009e7 <monitor+0x65>
f0100abf:	89 f8                	mov    %edi,%eax
f0100ac1:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100ac4:	83 ec 04             	sub    $0x4,%esp
f0100ac7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aca:	ff 75 08             	pushl  0x8(%ebp)
f0100acd:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ad0:	52                   	push   %edx
f0100ad1:	57                   	push   %edi
f0100ad2:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ad9:	83 c4 10             	add    $0x10,%esp
f0100adc:	85 c0                	test   %eax,%eax
f0100ade:	79 b6                	jns    f0100a96 <monitor+0x114>
				break;
	}
}
f0100ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae3:	5b                   	pop    %ebx
f0100ae4:	5e                   	pop    %esi
f0100ae5:	5f                   	pop    %edi
f0100ae6:	5d                   	pop    %ebp
f0100ae7:	c3                   	ret    

f0100ae8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ae8:	e8 42 25 00 00       	call   f010302f <__x86.get_pc_thunk.dx>
f0100aed:	81 c2 1b 78 01 00    	add    $0x1781b,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af3:	83 ba 90 1f 00 00 00 	cmpl   $0x0,0x1f90(%edx)
f0100afa:	74 1b                	je     f0100b17 <boot_alloc+0x2f>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100afc:	8b 8a 90 1f 00 00    	mov    0x1f90(%edx),%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b02:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b0e:	89 82 90 1f 00 00    	mov    %eax,0x1f90(%edx)
	return result;
}
f0100b14:	89 c8                	mov    %ecx,%eax
f0100b16:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b17:	c7 c1 a0 a6 11 f0    	mov    $0xf011a6a0,%ecx
f0100b1d:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100b23:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b29:	89 8a 90 1f 00 00    	mov    %ecx,0x1f90(%edx)
f0100b2f:	eb cb                	jmp    f0100afc <boot_alloc+0x14>

f0100b31 <nvram_read>:
{
f0100b31:	55                   	push   %ebp
f0100b32:	89 e5                	mov    %esp,%ebp
f0100b34:	57                   	push   %edi
f0100b35:	56                   	push   %esi
f0100b36:	53                   	push   %ebx
f0100b37:	83 ec 18             	sub    $0x18,%esp
f0100b3a:	e8 a1 f6 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0100b3f:	81 c3 c9 77 01 00    	add    $0x177c9,%ebx
f0100b45:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b47:	50                   	push   %eax
f0100b48:	e8 ee 24 00 00       	call   f010303b <mc146818_read>
f0100b4d:	89 c7                	mov    %eax,%edi
f0100b4f:	83 c6 01             	add    $0x1,%esi
f0100b52:	89 34 24             	mov    %esi,(%esp)
f0100b55:	e8 e1 24 00 00       	call   f010303b <mc146818_read>
f0100b5a:	c1 e0 08             	shl    $0x8,%eax
f0100b5d:	09 f8                	or     %edi,%eax
}
f0100b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b62:	5b                   	pop    %ebx
f0100b63:	5e                   	pop    %esi
f0100b64:	5f                   	pop    %edi
f0100b65:	5d                   	pop    %ebp
f0100b66:	c3                   	ret    

f0100b67 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b67:	55                   	push   %ebp
f0100b68:	89 e5                	mov    %esp,%ebp
f0100b6a:	56                   	push   %esi
f0100b6b:	53                   	push   %ebx
f0100b6c:	e8 c2 24 00 00       	call   f0103033 <__x86.get_pc_thunk.cx>
f0100b71:	81 c1 97 77 01 00    	add    $0x17797,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b77:	89 d3                	mov    %edx,%ebx
f0100b79:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b7c:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b7f:	a8 01                	test   $0x1,%al
f0100b81:	74 59                	je     f0100bdc <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b83:	89 c3                	mov    %eax,%ebx
f0100b85:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b8b:	c1 e8 0c             	shr    $0xc,%eax
f0100b8e:	c7 c6 a8 a6 11 f0    	mov    $0xf011a6a8,%esi
f0100b94:	3b 06                	cmp    (%esi),%eax
f0100b96:	73 29                	jae    f0100bc1 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100b98:	c1 ea 0c             	shr    $0xc,%edx
f0100b9b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ba1:	8b 94 93 00 00 00 f0 	mov    -0x10000000(%ebx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba8:	89 d0                	mov    %edx,%eax
f0100baa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100baf:	f6 c2 01             	test   $0x1,%dl
f0100bb2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bb7:	0f 44 c2             	cmove  %edx,%eax
}
f0100bba:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100bbd:	5b                   	pop    %ebx
f0100bbe:	5e                   	pop    %esi
f0100bbf:	5d                   	pop    %ebp
f0100bc0:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc1:	53                   	push   %ebx
f0100bc2:	8d 81 b0 c3 fe ff    	lea    -0x13c50(%ecx),%eax
f0100bc8:	50                   	push   %eax
f0100bc9:	68 f5 02 00 00       	push   $0x2f5
f0100bce:	8d 81 49 cb fe ff    	lea    -0x134b7(%ecx),%eax
f0100bd4:	50                   	push   %eax
f0100bd5:	89 cb                	mov    %ecx,%ebx
f0100bd7:	e8 46 f5 ff ff       	call   f0100122 <_panic>
		return ~0;
f0100bdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100be1:	eb d7                	jmp    f0100bba <check_va2pa+0x53>

f0100be3 <check_page_free_list>:
{
f0100be3:	55                   	push   %ebp
f0100be4:	89 e5                	mov    %esp,%ebp
f0100be6:	57                   	push   %edi
f0100be7:	56                   	push   %esi
f0100be8:	53                   	push   %ebx
f0100be9:	83 ec 2c             	sub    $0x2c,%esp
f0100bec:	e8 a7 fb ff ff       	call   f0100798 <__x86.get_pc_thunk.si>
f0100bf1:	81 c6 17 77 01 00    	add    $0x17717,%esi
f0100bf7:	89 75 c8             	mov    %esi,-0x38(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bfa:	84 c0                	test   %al,%al
f0100bfc:	0f 85 ec 02 00 00    	jne    f0100eee <check_page_free_list+0x30b>
	if (!page_free_list)
f0100c02:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100c05:	83 b8 94 1f 00 00 00 	cmpl   $0x0,0x1f94(%eax)
f0100c0c:	74 21                	je     f0100c2f <check_page_free_list+0x4c>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c0e:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c15:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100c18:	8b b0 94 1f 00 00    	mov    0x1f94(%eax),%esi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c1e:	c7 c7 b0 a6 11 f0    	mov    $0xf011a6b0,%edi
	if (PGNUM(pa) >= npages)
f0100c24:	c7 c0 a8 a6 11 f0    	mov    $0xf011a6a8,%eax
f0100c2a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c2d:	eb 39                	jmp    f0100c68 <check_page_free_list+0x85>
		panic("'page_free_list' is a null pointer!");
f0100c2f:	83 ec 04             	sub    $0x4,%esp
f0100c32:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c35:	8d 83 d4 c3 fe ff    	lea    -0x13c2c(%ebx),%eax
f0100c3b:	50                   	push   %eax
f0100c3c:	68 36 02 00 00       	push   $0x236
f0100c41:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100c47:	50                   	push   %eax
f0100c48:	e8 d5 f4 ff ff       	call   f0100122 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c4d:	50                   	push   %eax
f0100c4e:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100c51:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0100c57:	50                   	push   %eax
f0100c58:	6a 52                	push   $0x52
f0100c5a:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0100c60:	50                   	push   %eax
f0100c61:	e8 bc f4 ff ff       	call   f0100122 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c66:	8b 36                	mov    (%esi),%esi
f0100c68:	85 f6                	test   %esi,%esi
f0100c6a:	74 40                	je     f0100cac <check_page_free_list+0xc9>
	return (pp - pages) << PGSHIFT;
f0100c6c:	89 f0                	mov    %esi,%eax
f0100c6e:	2b 07                	sub    (%edi),%eax
f0100c70:	c1 f8 03             	sar    $0x3,%eax
f0100c73:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c76:	89 c2                	mov    %eax,%edx
f0100c78:	c1 ea 16             	shr    $0x16,%edx
f0100c7b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c7e:	73 e6                	jae    f0100c66 <check_page_free_list+0x83>
	if (PGNUM(pa) >= npages)
f0100c80:	89 c2                	mov    %eax,%edx
f0100c82:	c1 ea 0c             	shr    $0xc,%edx
f0100c85:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c88:	3b 11                	cmp    (%ecx),%edx
f0100c8a:	73 c1                	jae    f0100c4d <check_page_free_list+0x6a>
			memset(page2kva(pp), 0x97, 128);
f0100c8c:	83 ec 04             	sub    $0x4,%esp
f0100c8f:	68 80 00 00 00       	push   $0x80
f0100c94:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c99:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9e:	50                   	push   %eax
f0100c9f:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100ca2:	e8 90 30 00 00       	call   f0103d37 <memset>
f0100ca7:	83 c4 10             	add    $0x10,%esp
f0100caa:	eb ba                	jmp    f0100c66 <check_page_free_list+0x83>
	first_free_page = (char *) boot_alloc(0);
f0100cac:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb1:	e8 32 fe ff ff       	call   f0100ae8 <boot_alloc>
f0100cb6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb9:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0100cbc:	8b 97 94 1f 00 00    	mov    0x1f94(%edi),%edx
		assert(pp >= pages);
f0100cc2:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0100cc8:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100cca:	c7 c0 a8 a6 11 f0    	mov    $0xf011a6a8,%eax
f0100cd0:	8b 00                	mov    (%eax),%eax
f0100cd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cd5:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cdd:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce0:	e9 08 01 00 00       	jmp    f0100ded <check_page_free_list+0x20a>
		assert(pp >= pages);
f0100ce5:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100ce8:	8d 83 63 cb fe ff    	lea    -0x1349d(%ebx),%eax
f0100cee:	50                   	push   %eax
f0100cef:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100cf5:	50                   	push   %eax
f0100cf6:	68 50 02 00 00       	push   $0x250
f0100cfb:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100d01:	50                   	push   %eax
f0100d02:	e8 1b f4 ff ff       	call   f0100122 <_panic>
		assert(pp < pages + npages);
f0100d07:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d0a:	8d 83 84 cb fe ff    	lea    -0x1347c(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100d17:	50                   	push   %eax
f0100d18:	68 51 02 00 00       	push   $0x251
f0100d1d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100d23:	50                   	push   %eax
f0100d24:	e8 f9 f3 ff ff       	call   f0100122 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d29:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d2c:	8d 83 f8 c3 fe ff    	lea    -0x13c08(%ebx),%eax
f0100d32:	50                   	push   %eax
f0100d33:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100d39:	50                   	push   %eax
f0100d3a:	68 52 02 00 00       	push   $0x252
f0100d3f:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100d45:	50                   	push   %eax
f0100d46:	e8 d7 f3 ff ff       	call   f0100122 <_panic>
		assert(page2pa(pp) != 0);
f0100d4b:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d4e:	8d 83 98 cb fe ff    	lea    -0x13468(%ebx),%eax
f0100d54:	50                   	push   %eax
f0100d55:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100d5b:	50                   	push   %eax
f0100d5c:	68 55 02 00 00       	push   $0x255
f0100d61:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100d67:	50                   	push   %eax
f0100d68:	e8 b5 f3 ff ff       	call   f0100122 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6d:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d70:	8d 83 a9 cb fe ff    	lea    -0x13457(%ebx),%eax
f0100d76:	50                   	push   %eax
f0100d77:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100d7d:	50                   	push   %eax
f0100d7e:	68 56 02 00 00       	push   $0x256
f0100d83:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100d89:	50                   	push   %eax
f0100d8a:	e8 93 f3 ff ff       	call   f0100122 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8f:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d92:	8d 83 2c c4 fe ff    	lea    -0x13bd4(%ebx),%eax
f0100d98:	50                   	push   %eax
f0100d99:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100d9f:	50                   	push   %eax
f0100da0:	68 57 02 00 00       	push   $0x257
f0100da5:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100dab:	50                   	push   %eax
f0100dac:	e8 71 f3 ff ff       	call   f0100122 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db1:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100db4:	8d 83 c2 cb fe ff    	lea    -0x1343e(%ebx),%eax
f0100dba:	50                   	push   %eax
f0100dbb:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100dc1:	50                   	push   %eax
f0100dc2:	68 58 02 00 00       	push   $0x258
f0100dc7:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100dcd:	50                   	push   %eax
f0100dce:	e8 4f f3 ff ff       	call   f0100122 <_panic>
	if (PGNUM(pa) >= npages)
f0100dd3:	89 c3                	mov    %eax,%ebx
f0100dd5:	c1 eb 0c             	shr    $0xc,%ebx
f0100dd8:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100ddb:	76 6d                	jbe    f0100e4a <check_page_free_list+0x267>
	return (void *)(pa + KERNBASE);
f0100ddd:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de2:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100de5:	77 7c                	ja     f0100e63 <check_page_free_list+0x280>
			++nfree_extmem;
f0100de7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100deb:	8b 12                	mov    (%edx),%edx
f0100ded:	85 d2                	test   %edx,%edx
f0100def:	0f 84 90 00 00 00    	je     f0100e85 <check_page_free_list+0x2a2>
		assert(pp >= pages);
f0100df5:	39 d1                	cmp    %edx,%ecx
f0100df7:	0f 87 e8 fe ff ff    	ja     f0100ce5 <check_page_free_list+0x102>
		assert(pp < pages + npages);
f0100dfd:	39 d7                	cmp    %edx,%edi
f0100dff:	0f 86 02 ff ff ff    	jbe    f0100d07 <check_page_free_list+0x124>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e05:	89 d0                	mov    %edx,%eax
f0100e07:	29 c8                	sub    %ecx,%eax
f0100e09:	a8 07                	test   $0x7,%al
f0100e0b:	0f 85 18 ff ff ff    	jne    f0100d29 <check_page_free_list+0x146>
	return (pp - pages) << PGSHIFT;
f0100e11:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e14:	c1 e0 0c             	shl    $0xc,%eax
f0100e17:	0f 84 2e ff ff ff    	je     f0100d4b <check_page_free_list+0x168>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e1d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e22:	0f 84 45 ff ff ff    	je     f0100d6d <check_page_free_list+0x18a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e28:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e2d:	0f 84 5c ff ff ff    	je     f0100d8f <check_page_free_list+0x1ac>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e33:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e38:	0f 84 73 ff ff ff    	je     f0100db1 <check_page_free_list+0x1ce>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e3e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e43:	77 8e                	ja     f0100dd3 <check_page_free_list+0x1f0>
			++nfree_basemem;
f0100e45:	83 c6 01             	add    $0x1,%esi
f0100e48:	eb a1                	jmp    f0100deb <check_page_free_list+0x208>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e4a:	50                   	push   %eax
f0100e4b:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e4e:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0100e54:	50                   	push   %eax
f0100e55:	6a 52                	push   $0x52
f0100e57:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0100e5d:	50                   	push   %eax
f0100e5e:	e8 bf f2 ff ff       	call   f0100122 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e63:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e66:	8d 83 50 c4 fe ff    	lea    -0x13bb0(%ebx),%eax
f0100e6c:	50                   	push   %eax
f0100e6d:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100e73:	50                   	push   %eax
f0100e74:	68 59 02 00 00       	push   $0x259
f0100e79:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100e7f:	50                   	push   %eax
f0100e80:	e8 9d f2 ff ff       	call   f0100122 <_panic>
f0100e85:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100e88:	85 f6                	test   %esi,%esi
f0100e8a:	7e 1e                	jle    f0100eaa <check_page_free_list+0x2c7>
	assert(nfree_extmem > 0);
f0100e8c:	85 db                	test   %ebx,%ebx
f0100e8e:	7e 3c                	jle    f0100ecc <check_page_free_list+0x2e9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e90:	83 ec 0c             	sub    $0xc,%esp
f0100e93:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100e96:	8d 83 98 c4 fe ff    	lea    -0x13b68(%ebx),%eax
f0100e9c:	50                   	push   %eax
f0100e9d:	e8 30 22 00 00       	call   f01030d2 <cprintf>
}
f0100ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ea5:	5b                   	pop    %ebx
f0100ea6:	5e                   	pop    %esi
f0100ea7:	5f                   	pop    %edi
f0100ea8:	5d                   	pop    %ebp
f0100ea9:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100eaa:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100ead:	8d 83 dc cb fe ff    	lea    -0x13424(%ebx),%eax
f0100eb3:	50                   	push   %eax
f0100eb4:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100eba:	50                   	push   %eax
f0100ebb:	68 61 02 00 00       	push   $0x261
f0100ec0:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100ec6:	50                   	push   %eax
f0100ec7:	e8 56 f2 ff ff       	call   f0100122 <_panic>
	assert(nfree_extmem > 0);
f0100ecc:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100ecf:	8d 83 ee cb fe ff    	lea    -0x13412(%ebx),%eax
f0100ed5:	50                   	push   %eax
f0100ed6:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0100edc:	50                   	push   %eax
f0100edd:	68 62 02 00 00       	push   $0x262
f0100ee2:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100ee8:	50                   	push   %eax
f0100ee9:	e8 34 f2 ff ff       	call   f0100122 <_panic>
	if (!page_free_list)
f0100eee:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100ef1:	8b 80 94 1f 00 00    	mov    0x1f94(%eax),%eax
f0100ef7:	85 c0                	test   %eax,%eax
f0100ef9:	0f 84 30 fd ff ff    	je     f0100c2f <check_page_free_list+0x4c>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100eff:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f02:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f05:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f08:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100f0b:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100f0e:	c7 c3 b0 a6 11 f0    	mov    $0xf011a6b0,%ebx
f0100f14:	89 c2                	mov    %eax,%edx
f0100f16:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f18:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f1e:	0f 95 c2             	setne  %dl
f0100f21:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f24:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f28:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f2a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f2e:	8b 00                	mov    (%eax),%eax
f0100f30:	85 c0                	test   %eax,%eax
f0100f32:	75 e0                	jne    f0100f14 <check_page_free_list+0x331>
		*tp[1] = 0;
f0100f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f43:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f45:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f48:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100f4b:	89 86 94 1f 00 00    	mov    %eax,0x1f94(%esi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f51:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100f58:	e9 b8 fc ff ff       	jmp    f0100c15 <check_page_free_list+0x32>

f0100f5d <page_init>:
{
f0100f5d:	f3 0f 1e fb          	endbr32 
f0100f61:	55                   	push   %ebp
f0100f62:	89 e5                	mov    %esp,%ebp
f0100f64:	57                   	push   %edi
f0100f65:	56                   	push   %esi
f0100f66:	53                   	push   %ebx
f0100f67:	83 ec 1c             	sub    $0x1c,%esp
f0100f6a:	e8 25 f8 ff ff       	call   f0100794 <__x86.get_pc_thunk.ax>
f0100f6f:	05 99 73 01 00       	add    $0x17399,%eax
f0100f74:	89 45 d8             	mov    %eax,-0x28(%ebp)
	size_t EXT_Used_end = PADDR(boot_alloc(0)) / PGSIZE; //the end of used extended memory
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7c:	e8 67 fb ff ff       	call   f0100ae8 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f81:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f86:	76 46                	jbe    f0100fce <page_init+0x71>
	return (physaddr_t)kva - KERNBASE;
f0100f88:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f8d:	c1 e8 0c             	shr    $0xc,%eax
f0100f90:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pages[0].pp_ref = 1;
f0100f93:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100f96:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0100f9c:	8b 00                	mov    (%eax),%eax
f0100f9e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0100fa4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100faa:	8b b7 94 1f 00 00    	mov    0x1f94(%edi),%esi
	for (i = 1; i < npages; i++) {
f0100fb0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fb5:	b8 01 00 00 00       	mov    $0x1,%eax
f0100fba:	c7 c3 a8 a6 11 f0    	mov    $0xf011a6a8,%ebx
			pages[i].pp_ref = 0;
f0100fc0:	c7 c2 b0 a6 11 f0    	mov    $0xf011a6b0,%edx
f0100fc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			pages[i].pp_ref = 1;
f0100fc9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	for (i = 1; i < npages; i++) {
f0100fcc:	eb 33                	jmp    f0101001 <page_init+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fce:	50                   	push   %eax
f0100fcf:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100fd2:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f0100fd8:	50                   	push   %eax
f0100fd9:	68 10 01 00 00       	push   $0x110
f0100fde:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0100fe4:	50                   	push   %eax
f0100fe5:	e8 38 f1 ff ff       	call   f0100122 <_panic>
			pages[i].pp_ref = 1;
f0100fea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fed:	8b 12                	mov    (%edx),%edx
f0100fef:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100ff2:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ff8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 1; i < npages; i++) {
f0100ffe:	83 c0 01             	add    $0x1,%eax
f0101001:	39 03                	cmp    %eax,(%ebx)
f0101003:	76 30                	jbe    f0101035 <page_init+0xd8>
		if(i>= IO_Hole_start && i < EXT_Used_end){
f0101005:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f010100a:	76 05                	jbe    f0101011 <page_init+0xb4>
f010100c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010100f:	72 d9                	jb     f0100fea <page_init+0x8d>
f0101011:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0101018:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010101b:	89 d7                	mov    %edx,%edi
f010101d:	03 39                	add    (%ecx),%edi
f010101f:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0101025:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];
f0101027:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010102a:	89 d6                	mov    %edx,%esi
f010102c:	03 31                	add    (%ecx),%esi
f010102e:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101033:	eb c9                	jmp    f0100ffe <page_init+0xa1>
f0101035:	84 c9                	test   %cl,%cl
f0101037:	74 09                	je     f0101042 <page_init+0xe5>
f0101039:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010103c:	89 b0 94 1f 00 00    	mov    %esi,0x1f94(%eax)
}
f0101042:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101045:	5b                   	pop    %ebx
f0101046:	5e                   	pop    %esi
f0101047:	5f                   	pop    %edi
f0101048:	5d                   	pop    %ebp
f0101049:	c3                   	ret    

f010104a <page_alloc>:
{
f010104a:	f3 0f 1e fb          	endbr32 
f010104e:	55                   	push   %ebp
f010104f:	89 e5                	mov    %esp,%ebp
f0101051:	56                   	push   %esi
f0101052:	53                   	push   %ebx
f0101053:	e8 88 f1 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0101058:	81 c3 b0 72 01 00    	add    $0x172b0,%ebx
	struct PageInfo *result = page_free_list;
f010105e:	8b b3 94 1f 00 00    	mov    0x1f94(%ebx),%esi
	if (page_free_list != NULL){
f0101064:	85 f6                	test   %esi,%esi
f0101066:	74 1d                	je     f0101085 <page_alloc+0x3b>
		page_free_list = page_free_list -> pp_link;
f0101068:	8b 06                	mov    (%esi),%eax
f010106a:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
		result -> pp_link = NULL;
f0101070:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if((alloc_flags & ALLOC_ZERO) && result != NULL){
f0101076:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010107a:	75 1d                	jne    f0101099 <page_alloc+0x4f>
}
f010107c:	89 f0                	mov    %esi,%eax
f010107e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101081:	5b                   	pop    %ebx
f0101082:	5e                   	pop    %esi
f0101083:	5d                   	pop    %ebp
f0101084:	c3                   	ret    
		cprintf("Out of free memory!\n");
f0101085:	83 ec 0c             	sub    $0xc,%esp
f0101088:	8d 83 ff cb fe ff    	lea    -0x13401(%ebx),%eax
f010108e:	50                   	push   %eax
f010108f:	e8 3e 20 00 00       	call   f01030d2 <cprintf>
		return NULL;
f0101094:	83 c4 10             	add    $0x10,%esp
f0101097:	eb e3                	jmp    f010107c <page_alloc+0x32>
	return (pp - pages) << PGSHIFT;
f0101099:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f010109f:	89 f1                	mov    %esi,%ecx
f01010a1:	2b 08                	sub    (%eax),%ecx
f01010a3:	89 c8                	mov    %ecx,%eax
f01010a5:	c1 f8 03             	sar    $0x3,%eax
f01010a8:	89 c2                	mov    %eax,%edx
f01010aa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01010ad:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01010b2:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f01010b8:	3b 01                	cmp    (%ecx),%eax
f01010ba:	73 1b                	jae    f01010d7 <page_alloc+0x8d>
		memset((struct PageInfo*)page2kva(result), '\0', PGSIZE);
f01010bc:	83 ec 04             	sub    $0x4,%esp
f01010bf:	68 00 10 00 00       	push   $0x1000
f01010c4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010c6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010cc:	52                   	push   %edx
f01010cd:	e8 65 2c 00 00       	call   f0103d37 <memset>
f01010d2:	83 c4 10             	add    $0x10,%esp
f01010d5:	eb a5                	jmp    f010107c <page_alloc+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d7:	52                   	push   %edx
f01010d8:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f01010de:	50                   	push   %eax
f01010df:	6a 52                	push   $0x52
f01010e1:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f01010e7:	50                   	push   %eax
f01010e8:	e8 35 f0 ff ff       	call   f0100122 <_panic>

f01010ed <page_free>:
{
f01010ed:	f3 0f 1e fb          	endbr32 
f01010f1:	55                   	push   %ebp
f01010f2:	89 e5                	mov    %esp,%ebp
f01010f4:	53                   	push   %ebx
f01010f5:	83 ec 04             	sub    $0x4,%esp
f01010f8:	e8 e3 f0 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01010fd:	81 c3 0b 72 01 00    	add    $0x1720b,%ebx
f0101103:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0){
f0101106:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010110b:	75 18                	jne    f0101125 <page_free+0x38>
	if(pp->pp_link != NULL){
f010110d:	83 38 00             	cmpl   $0x0,(%eax)
f0101110:	75 2e                	jne    f0101140 <page_free+0x53>
	pp->pp_link = page_free_list;
f0101112:	8b 8b 94 1f 00 00    	mov    0x1f94(%ebx),%ecx
f0101118:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f010111a:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f0101120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101123:	c9                   	leave  
f0101124:	c3                   	ret    
		panic("page reference is nonzero!\n");
f0101125:	83 ec 04             	sub    $0x4,%esp
f0101128:	8d 83 14 cc fe ff    	lea    -0x133ec(%ebx),%eax
f010112e:	50                   	push   %eax
f010112f:	68 50 01 00 00       	push   $0x150
f0101134:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010113a:	50                   	push   %eax
f010113b:	e8 e2 ef ff ff       	call   f0100122 <_panic>
		panic("Double Free Error!\n");
f0101140:	83 ec 04             	sub    $0x4,%esp
f0101143:	8d 83 30 cc fe ff    	lea    -0x133d0(%ebx),%eax
f0101149:	50                   	push   %eax
f010114a:	68 53 01 00 00       	push   $0x153
f010114f:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101155:	50                   	push   %eax
f0101156:	e8 c7 ef ff ff       	call   f0100122 <_panic>

f010115b <page_decref>:
{
f010115b:	f3 0f 1e fb          	endbr32 
f010115f:	55                   	push   %ebp
f0101160:	89 e5                	mov    %esp,%ebp
f0101162:	83 ec 08             	sub    $0x8,%esp
f0101165:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101168:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010116c:	83 e8 01             	sub    $0x1,%eax
f010116f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101173:	66 85 c0             	test   %ax,%ax
f0101176:	74 02                	je     f010117a <page_decref+0x1f>
}
f0101178:	c9                   	leave  
f0101179:	c3                   	ret    
		page_free(pp);
f010117a:	83 ec 0c             	sub    $0xc,%esp
f010117d:	52                   	push   %edx
f010117e:	e8 6a ff ff ff       	call   f01010ed <page_free>
f0101183:	83 c4 10             	add    $0x10,%esp
}
f0101186:	eb f0                	jmp    f0101178 <page_decref+0x1d>

f0101188 <pgdir_walk>:
{	
f0101188:	f3 0f 1e fb          	endbr32 
f010118c:	55                   	push   %ebp
f010118d:	89 e5                	mov    %esp,%ebp
f010118f:	57                   	push   %edi
f0101190:	56                   	push   %esi
f0101191:	53                   	push   %ebx
f0101192:	83 ec 0c             	sub    $0xc,%esp
f0101195:	e8 9d 1e 00 00       	call   f0103037 <__x86.get_pc_thunk.di>
f010119a:	81 c7 6e 71 01 00    	add    $0x1716e,%edi
f01011a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t pgdir_entry = pgdir[PDX(va)]; //page directory entry, also physical address
f01011a3:	89 f3                	mov    %esi,%ebx
f01011a5:	c1 eb 16             	shr    $0x16,%ebx
f01011a8:	c1 e3 02             	shl    $0x2,%ebx
f01011ab:	03 5d 08             	add    0x8(%ebp),%ebx
f01011ae:	8b 03                	mov    (%ebx),%eax
	if(!(pgdir_entry & PTE_P))
f01011b0:	a8 01                	test   $0x1,%al
f01011b2:	75 7c                	jne    f0101230 <pgdir_walk+0xa8>
		if(create)
f01011b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011b8:	0f 84 ba 00 00 00    	je     f0101278 <pgdir_walk+0xf0>
			struct PageInfo *tmp = page_alloc(ALLOC_ZERO);//allocate an empty physical page
f01011be:	83 ec 0c             	sub    $0xc,%esp
f01011c1:	6a 01                	push   $0x1
f01011c3:	e8 82 fe ff ff       	call   f010104a <page_alloc>
			if (tmp == NULL)
f01011c8:	83 c4 10             	add    $0x10,%esp
f01011cb:	85 c0                	test   %eax,%eax
f01011cd:	0f 84 82 00 00 00    	je     f0101255 <pgdir_walk+0xcd>
				tmp->pp_ref++;// add reference to the physical page immediately
f01011d3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01011d8:	c7 c1 b0 a6 11 f0    	mov    $0xf011a6b0,%ecx
f01011de:	89 c2                	mov    %eax,%edx
f01011e0:	2b 11                	sub    (%ecx),%edx
f01011e2:	c1 fa 03             	sar    $0x3,%edx
f01011e5:	c1 e2 0c             	shl    $0xc,%edx
				pgdir[PDX(va)] = page2pa(tmp) | PTE_P | PTE_U | PTE_W;  //add page directory entry pointing to the newly created page table page
f01011e8:	83 ca 07             	or     $0x7,%edx
f01011eb:	89 13                	mov    %edx,(%ebx)
f01011ed:	2b 01                	sub    (%ecx),%eax
f01011ef:	c1 f8 03             	sar    $0x3,%eax
f01011f2:	89 c2                	mov    %eax,%edx
f01011f4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01011f7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01011fc:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0101202:	3b 01                	cmp    (%ecx),%eax
f0101204:	73 12                	jae    f0101218 <pgdir_walk+0x90>
				return &page_table[PTX(va)];
f0101206:	c1 ee 0a             	shr    $0xa,%esi
f0101209:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010120f:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
f0101216:	eb 3d                	jmp    f0101255 <pgdir_walk+0xcd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101218:	52                   	push   %edx
f0101219:	8d 87 b0 c3 fe ff    	lea    -0x13c50(%edi),%eax
f010121f:	50                   	push   %eax
f0101220:	6a 52                	push   $0x52
f0101222:	8d 87 55 cb fe ff    	lea    -0x134ab(%edi),%eax
f0101228:	50                   	push   %eax
f0101229:	89 fb                	mov    %edi,%ebx
f010122b:	e8 f2 ee ff ff       	call   f0100122 <_panic>
	pte_t* page_table = KADDR(PTE_ADDR(pgdir_entry)); //Retrieve the physical address of page table page from the page directory entry and convert it to virtual address.
f0101230:	89 c2                	mov    %eax,%edx
f0101232:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101238:	c1 e8 0c             	shr    $0xc,%eax
f010123b:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0101241:	3b 01                	cmp    (%ecx),%eax
f0101243:	73 18                	jae    f010125d <pgdir_walk+0xd5>
	return &page_table[PTX(va)];
f0101245:	c1 ee 0a             	shr    $0xa,%esi
f0101248:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010124e:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f0101255:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101258:	5b                   	pop    %ebx
f0101259:	5e                   	pop    %esi
f010125a:	5f                   	pop    %edi
f010125b:	5d                   	pop    %ebp
f010125c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010125d:	52                   	push   %edx
f010125e:	8d 87 b0 c3 fe ff    	lea    -0x13c50(%edi),%eax
f0101264:	50                   	push   %eax
f0101265:	68 97 01 00 00       	push   $0x197
f010126a:	8d 87 49 cb fe ff    	lea    -0x134b7(%edi),%eax
f0101270:	50                   	push   %eax
f0101271:	89 fb                	mov    %edi,%ebx
f0101273:	e8 aa ee ff ff       	call   f0100122 <_panic>
			return NULL;
f0101278:	b8 00 00 00 00       	mov    $0x0,%eax
f010127d:	eb d6                	jmp    f0101255 <pgdir_walk+0xcd>

f010127f <boot_map_region>:
{
f010127f:	55                   	push   %ebp
f0101280:	89 e5                	mov    %esp,%ebp
f0101282:	57                   	push   %edi
f0101283:	56                   	push   %esi
f0101284:	53                   	push   %ebx
f0101285:	83 ec 1c             	sub    $0x1c,%esp
f0101288:	e8 aa 1d 00 00       	call   f0103037 <__x86.get_pc_thunk.di>
f010128d:	81 c7 7b 70 01 00    	add    $0x1707b,%edi
f0101293:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0101296:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101299:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t page_needed = size / PGSIZE;
f010129c:	89 ce                	mov    %ecx,%esi
f010129e:	c1 ee 0c             	shr    $0xc,%esi
	if (size % PGSIZE != 0){
f01012a1:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		page_needed ++;  //In case size is not aligned.
f01012a7:	83 f9 01             	cmp    $0x1,%ecx
f01012aa:	83 de ff             	sbb    $0xffffffff,%esi
f01012ad:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	if (va % PGSIZE !=0) panic("va is not page-aligned!\n"); //Panic if va is not aligned.
f01012b0:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01012b6:	75 46                	jne    f01012fe <boot_map_region+0x7f>
f01012b8:	89 d7                	mov    %edx,%edi
	if (pa % PGSIZE !=0) panic("pa is not page-aligned!\n"); //Panic if pa is not aligned.
f01012ba:	89 c6                	mov    %eax,%esi
f01012bc:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
f01012c2:	75 58                	jne    f010131c <boot_map_region+0x9d>
f01012c4:	89 c3                	mov    %eax,%ebx
		pte_t *pp = pgdir_walk(pgdir, (void *)va, true);  //retrieve the pointer to the page table entry corresponding to the va. Maybe empty.
f01012c6:	29 c7                	sub    %eax,%edi
	for (i = 0; i < page_needed; i++){
f01012c8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01012cb:	0f 84 87 00 00 00    	je     f0101358 <boot_map_region+0xd9>
		pte_t *pp = pgdir_walk(pgdir, (void *)va, true);  //retrieve the pointer to the page table entry corresponding to the va. Maybe empty.
f01012d1:	83 ec 04             	sub    $0x4,%esp
f01012d4:	6a 01                	push   $0x1
f01012d6:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01012d9:	50                   	push   %eax
f01012da:	ff 75 e0             	pushl  -0x20(%ebp)
f01012dd:	e8 a6 fe ff ff       	call   f0101188 <pgdir_walk>
		if (pp == NULL){
f01012e2:	83 c4 10             	add    $0x10,%esp
f01012e5:	85 c0                	test   %eax,%eax
f01012e7:	74 51                	je     f010133a <boot_map_region+0xbb>
			*pp = pa | perm |PTE_P;  //point the page table entry to the given pa and set its permission.
f01012e9:	89 da                	mov    %ebx,%edx
f01012eb:	0b 55 0c             	or     0xc(%ebp),%edx
f01012ee:	83 ca 01             	or     $0x1,%edx
f01012f1:	89 10                	mov    %edx,(%eax)
			pa += PGSIZE;
f01012f3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < page_needed; i++){
f01012f9:	83 c6 01             	add    $0x1,%esi
f01012fc:	eb ca                	jmp    f01012c8 <boot_map_region+0x49>
	if (va % PGSIZE !=0) panic("va is not page-aligned!\n"); //Panic if va is not aligned.
f01012fe:	83 ec 04             	sub    $0x4,%esp
f0101301:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101304:	8d 83 44 cc fe ff    	lea    -0x133bc(%ebx),%eax
f010130a:	50                   	push   %eax
f010130b:	68 af 01 00 00       	push   $0x1af
f0101310:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101316:	50                   	push   %eax
f0101317:	e8 06 ee ff ff       	call   f0100122 <_panic>
	if (pa % PGSIZE !=0) panic("pa is not page-aligned!\n"); //Panic if pa is not aligned.
f010131c:	83 ec 04             	sub    $0x4,%esp
f010131f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101322:	8d 83 5d cc fe ff    	lea    -0x133a3(%ebx),%eax
f0101328:	50                   	push   %eax
f0101329:	68 b0 01 00 00       	push   $0x1b0
f010132e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101334:	50                   	push   %eax
f0101335:	e8 e8 ed ff ff       	call   f0100122 <_panic>
			panic("Fail to allocate Page Table Page! \n");
f010133a:	83 ec 04             	sub    $0x4,%esp
f010133d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101340:	8d 83 e0 c4 fe ff    	lea    -0x13b20(%ebx),%eax
f0101346:	50                   	push   %eax
f0101347:	68 b4 01 00 00       	push   $0x1b4
f010134c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101352:	50                   	push   %eax
f0101353:	e8 ca ed ff ff       	call   f0100122 <_panic>
}
f0101358:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010135b:	5b                   	pop    %ebx
f010135c:	5e                   	pop    %esi
f010135d:	5f                   	pop    %edi
f010135e:	5d                   	pop    %ebp
f010135f:	c3                   	ret    

f0101360 <page_lookup>:
{	// a little confused cuz the pointer. sorry that i know less about C-Programming...
f0101360:	f3 0f 1e fb          	endbr32 
f0101364:	55                   	push   %ebp
f0101365:	89 e5                	mov    %esp,%ebp
f0101367:	56                   	push   %esi
f0101368:	53                   	push   %ebx
f0101369:	e8 72 ee ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f010136e:	81 c3 9a 6f 01 00    	add    $0x16f9a,%ebx
f0101374:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t* pte = pgdir_walk(pgdir, va, 0);//Get the table entry of this page.
f0101377:	83 ec 04             	sub    $0x4,%esp
f010137a:	6a 00                	push   $0x0
f010137c:	ff 75 0c             	pushl  0xc(%ebp)
f010137f:	ff 75 08             	pushl  0x8(%ebp)
f0101382:	e8 01 fe ff ff       	call   f0101188 <pgdir_walk>
	if (!pte)
f0101387:	83 c4 10             	add    $0x10,%esp
f010138a:	85 c0                	test   %eax,%eax
f010138c:	74 20                	je     f01013ae <page_lookup+0x4e>
	if (pte_store)
f010138e:	85 f6                	test   %esi,%esi
f0101390:	74 02                	je     f0101394 <page_lookup+0x34>
		*pte_store = pte;
f0101392:	89 06                	mov    %eax,(%esi)
f0101394:	8b 00                	mov    (%eax),%eax
f0101396:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101399:	c7 c2 a8 a6 11 f0    	mov    $0xf011a6a8,%edx
f010139f:	39 02                	cmp    %eax,(%edx)
f01013a1:	76 12                	jbe    f01013b5 <page_lookup+0x55>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01013a3:	c7 c2 b0 a6 11 f0    	mov    $0xf011a6b0,%edx
f01013a9:	8b 12                	mov    (%edx),%edx
f01013ab:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01013ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013b1:	5b                   	pop    %ebx
f01013b2:	5e                   	pop    %esi
f01013b3:	5d                   	pop    %ebp
f01013b4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01013b5:	83 ec 04             	sub    $0x4,%esp
f01013b8:	8d 83 04 c5 fe ff    	lea    -0x13afc(%ebx),%eax
f01013be:	50                   	push   %eax
f01013bf:	6a 4b                	push   $0x4b
f01013c1:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f01013c7:	50                   	push   %eax
f01013c8:	e8 55 ed ff ff       	call   f0100122 <_panic>

f01013cd <page_remove>:
{
f01013cd:	f3 0f 1e fb          	endbr32 
f01013d1:	55                   	push   %ebp
f01013d2:	89 e5                	mov    %esp,%ebp
f01013d4:	53                   	push   %ebx
f01013d5:	83 ec 18             	sub    $0x18,%esp
f01013d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *p = 0;
f01013db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &p); //retrieve the physical page corresponding to va and store the pte pointer in p.
f01013e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013e5:	50                   	push   %eax
f01013e6:	53                   	push   %ebx
f01013e7:	ff 75 08             	pushl  0x8(%ebp)
f01013ea:	e8 71 ff ff ff       	call   f0101360 <page_lookup>
	if (page == NULL) return; //Silently did nothing
f01013ef:	83 c4 10             	add    $0x10,%esp
f01013f2:	85 c0                	test   %eax,%eax
f01013f4:	74 18                	je     f010140e <page_remove+0x41>
	page_decref(page); //decrease reference. Also free the page automatically when the reference reaches 0.
f01013f6:	83 ec 0c             	sub    $0xc,%esp
f01013f9:	50                   	push   %eax
f01013fa:	e8 5c fd ff ff       	call   f010115b <page_decref>
	*p = 0; //Clear the pte
f01013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101408:	0f 01 3b             	invlpg (%ebx)
f010140b:	83 c4 10             	add    $0x10,%esp
}
f010140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101411:	c9                   	leave  
f0101412:	c3                   	ret    

f0101413 <page_insert>:
{
f0101413:	f3 0f 1e fb          	endbr32 
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	57                   	push   %edi
f010141b:	56                   	push   %esi
f010141c:	53                   	push   %ebx
f010141d:	83 ec 10             	sub    $0x10,%esp
f0101420:	e8 12 1c 00 00       	call   f0103037 <__x86.get_pc_thunk.di>
f0101425:	81 c7 e3 6e 01 00    	add    $0x16ee3,%edi
f010142b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* p_pte = pgdir_walk(pgdir, va, true);   //retrieve the pointer to pte corresponding to va. May allocate one if not exist.
f010142e:	6a 01                	push   $0x1
f0101430:	ff 75 10             	pushl  0x10(%ebp)
f0101433:	ff 75 08             	pushl  0x8(%ebp)
f0101436:	e8 4d fd ff ff       	call   f0101188 <pgdir_walk>
	if (p_pte == NULL) return -E_NO_MEM; //if page table fail to be allocated.
f010143b:	83 c4 10             	add    $0x10,%esp
f010143e:	85 c0                	test   %eax,%eax
f0101440:	74 48                	je     f010148a <page_insert+0x77>
f0101442:	89 c6                	mov    %eax,%esi
	pp->pp_ref ++;  //First increase reference
f0101444:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*p_pte) & PTE_P) page_remove(pgdir, va); //Then decrease reference in case the page is freed wrongly in the re-inserted situation.
f0101449:	f6 00 01             	testb  $0x1,(%eax)
f010144c:	75 29                	jne    f0101477 <page_insert+0x64>
	return (pp - pages) << PGSHIFT;
f010144e:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101454:	2b 18                	sub    (%eax),%ebx
f0101456:	c1 fb 03             	sar    $0x3,%ebx
f0101459:	c1 e3 0c             	shl    $0xc,%ebx
	*p_pte = page2pa(pp) | perm |PTE_P; //Set the page table entry
f010145c:	0b 5d 14             	or     0x14(%ebp),%ebx
f010145f:	83 cb 01             	or     $0x1,%ebx
f0101462:	89 1e                	mov    %ebx,(%esi)
f0101464:	8b 45 10             	mov    0x10(%ebp),%eax
f0101467:	0f 01 38             	invlpg (%eax)
	return 0;
f010146a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010146f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101472:	5b                   	pop    %ebx
f0101473:	5e                   	pop    %esi
f0101474:	5f                   	pop    %edi
f0101475:	5d                   	pop    %ebp
f0101476:	c3                   	ret    
	if((*p_pte) & PTE_P) page_remove(pgdir, va); //Then decrease reference in case the page is freed wrongly in the re-inserted situation.
f0101477:	83 ec 08             	sub    $0x8,%esp
f010147a:	ff 75 10             	pushl  0x10(%ebp)
f010147d:	ff 75 08             	pushl  0x8(%ebp)
f0101480:	e8 48 ff ff ff       	call   f01013cd <page_remove>
f0101485:	83 c4 10             	add    $0x10,%esp
f0101488:	eb c4                	jmp    f010144e <page_insert+0x3b>
	if (p_pte == NULL) return -E_NO_MEM; //if page table fail to be allocated.
f010148a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010148f:	eb de                	jmp    f010146f <page_insert+0x5c>

f0101491 <mem_init>:
{
f0101491:	f3 0f 1e fb          	endbr32 
f0101495:	55                   	push   %ebp
f0101496:	89 e5                	mov    %esp,%ebp
f0101498:	57                   	push   %edi
f0101499:	56                   	push   %esi
f010149a:	53                   	push   %ebx
f010149b:	83 ec 3c             	sub    $0x3c,%esp
f010149e:	e8 3d ed ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01014a3:	81 c3 65 6e 01 00    	add    $0x16e65,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f01014a9:	b8 15 00 00 00       	mov    $0x15,%eax
f01014ae:	e8 7e f6 ff ff       	call   f0100b31 <nvram_read>
f01014b3:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01014b5:	b8 17 00 00 00       	mov    $0x17,%eax
f01014ba:	e8 72 f6 ff ff       	call   f0100b31 <nvram_read>
f01014bf:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014c1:	b8 34 00 00 00       	mov    $0x34,%eax
f01014c6:	e8 66 f6 ff ff       	call   f0100b31 <nvram_read>
	if (ext16mem)
f01014cb:	c1 e0 06             	shl    $0x6,%eax
f01014ce:	0f 84 bb 00 00 00    	je     f010158f <mem_init+0xfe>
		totalmem = 16 * 1024 + ext16mem;
f01014d4:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01014d9:	89 c1                	mov    %eax,%ecx
f01014db:	c1 e9 02             	shr    $0x2,%ecx
f01014de:	c7 c2 a8 a6 11 f0    	mov    $0xf011a6a8,%edx
f01014e4:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014e6:	89 c2                	mov    %eax,%edx
f01014e8:	29 f2                	sub    %esi,%edx
f01014ea:	52                   	push   %edx
f01014eb:	56                   	push   %esi
f01014ec:	50                   	push   %eax
f01014ed:	8d 83 24 c5 fe ff    	lea    -0x13adc(%ebx),%eax
f01014f3:	50                   	push   %eax
f01014f4:	e8 d9 1b 00 00       	call   f01030d2 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014f9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014fe:	e8 e5 f5 ff ff       	call   f0100ae8 <boot_alloc>
f0101503:	c7 c6 ac a6 11 f0    	mov    $0xf011a6ac,%esi
f0101509:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f010150b:	83 c4 0c             	add    $0xc,%esp
f010150e:	68 00 10 00 00       	push   $0x1000
f0101513:	6a 00                	push   $0x0
f0101515:	50                   	push   %eax
f0101516:	e8 1c 28 00 00       	call   f0103d37 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010151b:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010151d:	83 c4 10             	add    $0x10,%esp
f0101520:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101525:	76 78                	jbe    f010159f <mem_init+0x10e>
	return (physaddr_t)kva - KERNBASE;
f0101527:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010152d:	83 ca 05             	or     $0x5,%edx
f0101530:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*) boot_alloc(sizeof(struct PageInfo) * npages);
f0101536:	c7 c7 a8 a6 11 f0    	mov    $0xf011a6a8,%edi
f010153c:	8b 07                	mov    (%edi),%eax
f010153e:	c1 e0 03             	shl    $0x3,%eax
f0101541:	e8 a2 f5 ff ff       	call   f0100ae8 <boot_alloc>
f0101546:	c7 c6 b0 a6 11 f0    	mov    $0xf011a6b0,%esi
f010154c:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f010154e:	83 ec 04             	sub    $0x4,%esp
f0101551:	8b 17                	mov    (%edi),%edx
f0101553:	c1 e2 03             	shl    $0x3,%edx
f0101556:	52                   	push   %edx
f0101557:	6a 00                	push   $0x0
f0101559:	50                   	push   %eax
f010155a:	e8 d8 27 00 00       	call   f0103d37 <memset>
	page_init();
f010155f:	e8 f9 f9 ff ff       	call   f0100f5d <page_init>
	check_page_free_list(1);
f0101564:	b8 01 00 00 00       	mov    $0x1,%eax
f0101569:	e8 75 f6 ff ff       	call   f0100be3 <check_page_free_list>
	if (!pages)
f010156e:	83 c4 10             	add    $0x10,%esp
f0101571:	83 3e 00             	cmpl   $0x0,(%esi)
f0101574:	74 42                	je     f01015b8 <mem_init+0x127>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101576:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f010157c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0101583:	85 c0                	test   %eax,%eax
f0101585:	74 4c                	je     f01015d3 <mem_init+0x142>
		++nfree;
f0101587:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010158b:	8b 00                	mov    (%eax),%eax
f010158d:	eb f4                	jmp    f0101583 <mem_init+0xf2>
		totalmem = 1 * 1024 + extmem;
f010158f:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f0101595:	85 ff                	test   %edi,%edi
f0101597:	0f 44 c6             	cmove  %esi,%eax
f010159a:	e9 3a ff ff ff       	jmp    f01014d9 <mem_init+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010159f:	50                   	push   %eax
f01015a0:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f01015a6:	50                   	push   %eax
f01015a7:	68 8f 00 00 00       	push   $0x8f
f01015ac:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01015b2:	50                   	push   %eax
f01015b3:	e8 6a eb ff ff       	call   f0100122 <_panic>
		panic("'pages' is a null pointer!");
f01015b8:	83 ec 04             	sub    $0x4,%esp
f01015bb:	8d 83 76 cc fe ff    	lea    -0x1338a(%ebx),%eax
f01015c1:	50                   	push   %eax
f01015c2:	68 75 02 00 00       	push   $0x275
f01015c7:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01015cd:	50                   	push   %eax
f01015ce:	e8 4f eb ff ff       	call   f0100122 <_panic>
	assert((pp0 = page_alloc(0)));
f01015d3:	83 ec 0c             	sub    $0xc,%esp
f01015d6:	6a 00                	push   $0x0
f01015d8:	e8 6d fa ff ff       	call   f010104a <page_alloc>
f01015dd:	89 c6                	mov    %eax,%esi
f01015df:	83 c4 10             	add    $0x10,%esp
f01015e2:	85 c0                	test   %eax,%eax
f01015e4:	0f 84 31 02 00 00    	je     f010181b <mem_init+0x38a>
	assert((pp1 = page_alloc(0)));
f01015ea:	83 ec 0c             	sub    $0xc,%esp
f01015ed:	6a 00                	push   $0x0
f01015ef:	e8 56 fa ff ff       	call   f010104a <page_alloc>
f01015f4:	89 c7                	mov    %eax,%edi
f01015f6:	83 c4 10             	add    $0x10,%esp
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	0f 84 39 02 00 00    	je     f010183a <mem_init+0x3a9>
	assert((pp2 = page_alloc(0)));
f0101601:	83 ec 0c             	sub    $0xc,%esp
f0101604:	6a 00                	push   $0x0
f0101606:	e8 3f fa ff ff       	call   f010104a <page_alloc>
f010160b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010160e:	83 c4 10             	add    $0x10,%esp
f0101611:	85 c0                	test   %eax,%eax
f0101613:	0f 84 40 02 00 00    	je     f0101859 <mem_init+0x3c8>
	assert(pp1 && pp1 != pp0);
f0101619:	39 fe                	cmp    %edi,%esi
f010161b:	0f 84 57 02 00 00    	je     f0101878 <mem_init+0x3e7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101621:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101624:	39 c6                	cmp    %eax,%esi
f0101626:	0f 84 6b 02 00 00    	je     f0101897 <mem_init+0x406>
f010162c:	39 c7                	cmp    %eax,%edi
f010162e:	0f 84 63 02 00 00    	je     f0101897 <mem_init+0x406>
	return (pp - pages) << PGSHIFT;
f0101634:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f010163a:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010163c:	c7 c0 a8 a6 11 f0    	mov    $0xf011a6a8,%eax
f0101642:	8b 10                	mov    (%eax),%edx
f0101644:	c1 e2 0c             	shl    $0xc,%edx
f0101647:	89 f0                	mov    %esi,%eax
f0101649:	29 c8                	sub    %ecx,%eax
f010164b:	c1 f8 03             	sar    $0x3,%eax
f010164e:	c1 e0 0c             	shl    $0xc,%eax
f0101651:	39 d0                	cmp    %edx,%eax
f0101653:	0f 83 5d 02 00 00    	jae    f01018b6 <mem_init+0x425>
f0101659:	89 f8                	mov    %edi,%eax
f010165b:	29 c8                	sub    %ecx,%eax
f010165d:	c1 f8 03             	sar    $0x3,%eax
f0101660:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101663:	39 c2                	cmp    %eax,%edx
f0101665:	0f 86 6a 02 00 00    	jbe    f01018d5 <mem_init+0x444>
f010166b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166e:	29 c8                	sub    %ecx,%eax
f0101670:	c1 f8 03             	sar    $0x3,%eax
f0101673:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101676:	39 c2                	cmp    %eax,%edx
f0101678:	0f 86 76 02 00 00    	jbe    f01018f4 <mem_init+0x463>
	fl = page_free_list;
f010167e:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101684:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101687:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f010168e:	00 00 00 
	assert(!page_alloc(0));
f0101691:	83 ec 0c             	sub    $0xc,%esp
f0101694:	6a 00                	push   $0x0
f0101696:	e8 af f9 ff ff       	call   f010104a <page_alloc>
f010169b:	83 c4 10             	add    $0x10,%esp
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	0f 85 6d 02 00 00    	jne    f0101913 <mem_init+0x482>
	page_free(pp0);
f01016a6:	83 ec 0c             	sub    $0xc,%esp
f01016a9:	56                   	push   %esi
f01016aa:	e8 3e fa ff ff       	call   f01010ed <page_free>
	page_free(pp1);
f01016af:	89 3c 24             	mov    %edi,(%esp)
f01016b2:	e8 36 fa ff ff       	call   f01010ed <page_free>
	page_free(pp2);
f01016b7:	83 c4 04             	add    $0x4,%esp
f01016ba:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016bd:	e8 2b fa ff ff       	call   f01010ed <page_free>
	assert((pp0 = page_alloc(0)));
f01016c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c9:	e8 7c f9 ff ff       	call   f010104a <page_alloc>
f01016ce:	89 c6                	mov    %eax,%esi
f01016d0:	83 c4 10             	add    $0x10,%esp
f01016d3:	85 c0                	test   %eax,%eax
f01016d5:	0f 84 57 02 00 00    	je     f0101932 <mem_init+0x4a1>
	assert((pp1 = page_alloc(0)));
f01016db:	83 ec 0c             	sub    $0xc,%esp
f01016de:	6a 00                	push   $0x0
f01016e0:	e8 65 f9 ff ff       	call   f010104a <page_alloc>
f01016e5:	89 c7                	mov    %eax,%edi
f01016e7:	83 c4 10             	add    $0x10,%esp
f01016ea:	85 c0                	test   %eax,%eax
f01016ec:	0f 84 5f 02 00 00    	je     f0101951 <mem_init+0x4c0>
	assert((pp2 = page_alloc(0)));
f01016f2:	83 ec 0c             	sub    $0xc,%esp
f01016f5:	6a 00                	push   $0x0
f01016f7:	e8 4e f9 ff ff       	call   f010104a <page_alloc>
f01016fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016ff:	83 c4 10             	add    $0x10,%esp
f0101702:	85 c0                	test   %eax,%eax
f0101704:	0f 84 66 02 00 00    	je     f0101970 <mem_init+0x4df>
	assert(pp1 && pp1 != pp0);
f010170a:	39 fe                	cmp    %edi,%esi
f010170c:	0f 84 7d 02 00 00    	je     f010198f <mem_init+0x4fe>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101712:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101715:	39 c6                	cmp    %eax,%esi
f0101717:	0f 84 91 02 00 00    	je     f01019ae <mem_init+0x51d>
f010171d:	39 c7                	cmp    %eax,%edi
f010171f:	0f 84 89 02 00 00    	je     f01019ae <mem_init+0x51d>
	assert(!page_alloc(0));
f0101725:	83 ec 0c             	sub    $0xc,%esp
f0101728:	6a 00                	push   $0x0
f010172a:	e8 1b f9 ff ff       	call   f010104a <page_alloc>
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	85 c0                	test   %eax,%eax
f0101734:	0f 85 93 02 00 00    	jne    f01019cd <mem_init+0x53c>
f010173a:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101740:	89 f1                	mov    %esi,%ecx
f0101742:	2b 08                	sub    (%eax),%ecx
f0101744:	89 c8                	mov    %ecx,%eax
f0101746:	c1 f8 03             	sar    $0x3,%eax
f0101749:	89 c2                	mov    %eax,%edx
f010174b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010174e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101753:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0101759:	3b 01                	cmp    (%ecx),%eax
f010175b:	0f 83 8b 02 00 00    	jae    f01019ec <mem_init+0x55b>
	memset(page2kva(pp0), 1, PGSIZE);
f0101761:	83 ec 04             	sub    $0x4,%esp
f0101764:	68 00 10 00 00       	push   $0x1000
f0101769:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010176b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101771:	52                   	push   %edx
f0101772:	e8 c0 25 00 00       	call   f0103d37 <memset>
	page_free(pp0);
f0101777:	89 34 24             	mov    %esi,(%esp)
f010177a:	e8 6e f9 ff ff       	call   f01010ed <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010177f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101786:	e8 bf f8 ff ff       	call   f010104a <page_alloc>
f010178b:	83 c4 10             	add    $0x10,%esp
f010178e:	85 c0                	test   %eax,%eax
f0101790:	0f 84 6c 02 00 00    	je     f0101a02 <mem_init+0x571>
	assert(pp && pp0 == pp);
f0101796:	39 c6                	cmp    %eax,%esi
f0101798:	0f 85 83 02 00 00    	jne    f0101a21 <mem_init+0x590>
	return (pp - pages) << PGSHIFT;
f010179e:	c7 c2 b0 a6 11 f0    	mov    $0xf011a6b0,%edx
f01017a4:	2b 02                	sub    (%edx),%eax
f01017a6:	c1 f8 03             	sar    $0x3,%eax
f01017a9:	89 c2                	mov    %eax,%edx
f01017ab:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01017ae:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01017b3:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f01017b9:	3b 01                	cmp    (%ecx),%eax
f01017bb:	0f 83 7f 02 00 00    	jae    f0101a40 <mem_init+0x5af>
	return (void *)(pa + KERNBASE);
f01017c1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01017c7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01017cd:	80 38 00             	cmpb   $0x0,(%eax)
f01017d0:	0f 85 80 02 00 00    	jne    f0101a56 <mem_init+0x5c5>
f01017d6:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01017d9:	39 d0                	cmp    %edx,%eax
f01017db:	75 f0                	jne    f01017cd <mem_init+0x33c>
	page_free_list = fl;
f01017dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01017e0:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	page_free(pp0);
f01017e6:	83 ec 0c             	sub    $0xc,%esp
f01017e9:	56                   	push   %esi
f01017ea:	e8 fe f8 ff ff       	call   f01010ed <page_free>
	page_free(pp1);
f01017ef:	89 3c 24             	mov    %edi,(%esp)
f01017f2:	e8 f6 f8 ff ff       	call   f01010ed <page_free>
	page_free(pp2);
f01017f7:	83 c4 04             	add    $0x4,%esp
f01017fa:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017fd:	e8 eb f8 ff ff       	call   f01010ed <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101802:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101808:	83 c4 10             	add    $0x10,%esp
f010180b:	85 c0                	test   %eax,%eax
f010180d:	0f 84 62 02 00 00    	je     f0101a75 <mem_init+0x5e4>
		--nfree;
f0101813:	83 6d d0 01          	subl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101817:	8b 00                	mov    (%eax),%eax
f0101819:	eb f0                	jmp    f010180b <mem_init+0x37a>
	assert((pp0 = page_alloc(0)));
f010181b:	8d 83 91 cc fe ff    	lea    -0x1336f(%ebx),%eax
f0101821:	50                   	push   %eax
f0101822:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101828:	50                   	push   %eax
f0101829:	68 7d 02 00 00       	push   $0x27d
f010182e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101834:	50                   	push   %eax
f0101835:	e8 e8 e8 ff ff       	call   f0100122 <_panic>
	assert((pp1 = page_alloc(0)));
f010183a:	8d 83 a7 cc fe ff    	lea    -0x13359(%ebx),%eax
f0101840:	50                   	push   %eax
f0101841:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101847:	50                   	push   %eax
f0101848:	68 7e 02 00 00       	push   $0x27e
f010184d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101853:	50                   	push   %eax
f0101854:	e8 c9 e8 ff ff       	call   f0100122 <_panic>
	assert((pp2 = page_alloc(0)));
f0101859:	8d 83 bd cc fe ff    	lea    -0x13343(%ebx),%eax
f010185f:	50                   	push   %eax
f0101860:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101866:	50                   	push   %eax
f0101867:	68 7f 02 00 00       	push   $0x27f
f010186c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101872:	50                   	push   %eax
f0101873:	e8 aa e8 ff ff       	call   f0100122 <_panic>
	assert(pp1 && pp1 != pp0);
f0101878:	8d 83 d3 cc fe ff    	lea    -0x1332d(%ebx),%eax
f010187e:	50                   	push   %eax
f010187f:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101885:	50                   	push   %eax
f0101886:	68 82 02 00 00       	push   $0x282
f010188b:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101891:	50                   	push   %eax
f0101892:	e8 8b e8 ff ff       	call   f0100122 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101897:	8d 83 60 c5 fe ff    	lea    -0x13aa0(%ebx),%eax
f010189d:	50                   	push   %eax
f010189e:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01018a4:	50                   	push   %eax
f01018a5:	68 83 02 00 00       	push   $0x283
f01018aa:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01018b0:	50                   	push   %eax
f01018b1:	e8 6c e8 ff ff       	call   f0100122 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01018b6:	8d 83 e5 cc fe ff    	lea    -0x1331b(%ebx),%eax
f01018bc:	50                   	push   %eax
f01018bd:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01018c3:	50                   	push   %eax
f01018c4:	68 84 02 00 00       	push   $0x284
f01018c9:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01018cf:	50                   	push   %eax
f01018d0:	e8 4d e8 ff ff       	call   f0100122 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01018d5:	8d 83 02 cd fe ff    	lea    -0x132fe(%ebx),%eax
f01018db:	50                   	push   %eax
f01018dc:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01018e2:	50                   	push   %eax
f01018e3:	68 85 02 00 00       	push   $0x285
f01018e8:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01018ee:	50                   	push   %eax
f01018ef:	e8 2e e8 ff ff       	call   f0100122 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01018f4:	8d 83 1f cd fe ff    	lea    -0x132e1(%ebx),%eax
f01018fa:	50                   	push   %eax
f01018fb:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101901:	50                   	push   %eax
f0101902:	68 86 02 00 00       	push   $0x286
f0101907:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010190d:	50                   	push   %eax
f010190e:	e8 0f e8 ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f0101913:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f0101919:	50                   	push   %eax
f010191a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101920:	50                   	push   %eax
f0101921:	68 8d 02 00 00       	push   $0x28d
f0101926:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010192c:	50                   	push   %eax
f010192d:	e8 f0 e7 ff ff       	call   f0100122 <_panic>
	assert((pp0 = page_alloc(0)));
f0101932:	8d 83 91 cc fe ff    	lea    -0x1336f(%ebx),%eax
f0101938:	50                   	push   %eax
f0101939:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010193f:	50                   	push   %eax
f0101940:	68 94 02 00 00       	push   $0x294
f0101945:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010194b:	50                   	push   %eax
f010194c:	e8 d1 e7 ff ff       	call   f0100122 <_panic>
	assert((pp1 = page_alloc(0)));
f0101951:	8d 83 a7 cc fe ff    	lea    -0x13359(%ebx),%eax
f0101957:	50                   	push   %eax
f0101958:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010195e:	50                   	push   %eax
f010195f:	68 95 02 00 00       	push   $0x295
f0101964:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010196a:	50                   	push   %eax
f010196b:	e8 b2 e7 ff ff       	call   f0100122 <_panic>
	assert((pp2 = page_alloc(0)));
f0101970:	8d 83 bd cc fe ff    	lea    -0x13343(%ebx),%eax
f0101976:	50                   	push   %eax
f0101977:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010197d:	50                   	push   %eax
f010197e:	68 96 02 00 00       	push   $0x296
f0101983:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101989:	50                   	push   %eax
f010198a:	e8 93 e7 ff ff       	call   f0100122 <_panic>
	assert(pp1 && pp1 != pp0);
f010198f:	8d 83 d3 cc fe ff    	lea    -0x1332d(%ebx),%eax
f0101995:	50                   	push   %eax
f0101996:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010199c:	50                   	push   %eax
f010199d:	68 98 02 00 00       	push   $0x298
f01019a2:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01019a8:	50                   	push   %eax
f01019a9:	e8 74 e7 ff ff       	call   f0100122 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019ae:	8d 83 60 c5 fe ff    	lea    -0x13aa0(%ebx),%eax
f01019b4:	50                   	push   %eax
f01019b5:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01019bb:	50                   	push   %eax
f01019bc:	68 99 02 00 00       	push   $0x299
f01019c1:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01019c7:	50                   	push   %eax
f01019c8:	e8 55 e7 ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f01019cd:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f01019d3:	50                   	push   %eax
f01019d4:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01019da:	50                   	push   %eax
f01019db:	68 9a 02 00 00       	push   $0x29a
f01019e0:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01019e6:	50                   	push   %eax
f01019e7:	e8 36 e7 ff ff       	call   f0100122 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019ec:	52                   	push   %edx
f01019ed:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f01019f3:	50                   	push   %eax
f01019f4:	6a 52                	push   $0x52
f01019f6:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f01019fc:	50                   	push   %eax
f01019fd:	e8 20 e7 ff ff       	call   f0100122 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a02:	8d 83 4b cd fe ff    	lea    -0x132b5(%ebx),%eax
f0101a08:	50                   	push   %eax
f0101a09:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101a0f:	50                   	push   %eax
f0101a10:	68 9f 02 00 00       	push   $0x29f
f0101a15:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101a1b:	50                   	push   %eax
f0101a1c:	e8 01 e7 ff ff       	call   f0100122 <_panic>
	assert(pp && pp0 == pp);
f0101a21:	8d 83 69 cd fe ff    	lea    -0x13297(%ebx),%eax
f0101a27:	50                   	push   %eax
f0101a28:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101a2e:	50                   	push   %eax
f0101a2f:	68 a0 02 00 00       	push   $0x2a0
f0101a34:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101a3a:	50                   	push   %eax
f0101a3b:	e8 e2 e6 ff ff       	call   f0100122 <_panic>
f0101a40:	52                   	push   %edx
f0101a41:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0101a47:	50                   	push   %eax
f0101a48:	6a 52                	push   $0x52
f0101a4a:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0101a50:	50                   	push   %eax
f0101a51:	e8 cc e6 ff ff       	call   f0100122 <_panic>
		assert(c[i] == 0);
f0101a56:	8d 83 79 cd fe ff    	lea    -0x13287(%ebx),%eax
f0101a5c:	50                   	push   %eax
f0101a5d:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0101a63:	50                   	push   %eax
f0101a64:	68 a3 02 00 00       	push   $0x2a3
f0101a69:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0101a6f:	50                   	push   %eax
f0101a70:	e8 ad e6 ff ff       	call   f0100122 <_panic>
	assert(nfree == 0);
f0101a75:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101a79:	0f 85 57 08 00 00    	jne    f01022d6 <mem_init+0xe45>
	cprintf("check_page_alloc() succeeded!\n");
f0101a7f:	83 ec 0c             	sub    $0xc,%esp
f0101a82:	8d 83 80 c5 fe ff    	lea    -0x13a80(%ebx),%eax
f0101a88:	50                   	push   %eax
f0101a89:	e8 44 16 00 00       	call   f01030d2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a95:	e8 b0 f5 ff ff       	call   f010104a <page_alloc>
f0101a9a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a9d:	83 c4 10             	add    $0x10,%esp
f0101aa0:	85 c0                	test   %eax,%eax
f0101aa2:	0f 84 4d 08 00 00    	je     f01022f5 <mem_init+0xe64>
	assert((pp1 = page_alloc(0)));
f0101aa8:	83 ec 0c             	sub    $0xc,%esp
f0101aab:	6a 00                	push   $0x0
f0101aad:	e8 98 f5 ff ff       	call   f010104a <page_alloc>
f0101ab2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ab5:	83 c4 10             	add    $0x10,%esp
f0101ab8:	85 c0                	test   %eax,%eax
f0101aba:	0f 84 54 08 00 00    	je     f0102314 <mem_init+0xe83>
	assert((pp2 = page_alloc(0)));
f0101ac0:	83 ec 0c             	sub    $0xc,%esp
f0101ac3:	6a 00                	push   $0x0
f0101ac5:	e8 80 f5 ff ff       	call   f010104a <page_alloc>
f0101aca:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101acd:	83 c4 10             	add    $0x10,%esp
f0101ad0:	85 c0                	test   %eax,%eax
f0101ad2:	0f 84 5b 08 00 00    	je     f0102333 <mem_init+0xea2>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ad8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101adb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101ade:	0f 84 6e 08 00 00    	je     f0102352 <mem_init+0xec1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ae4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ae7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101aea:	0f 84 81 08 00 00    	je     f0102371 <mem_init+0xee0>
f0101af0:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101af3:	0f 84 78 08 00 00    	je     f0102371 <mem_init+0xee0>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101af9:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101aff:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101b02:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101b09:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b0c:	83 ec 0c             	sub    $0xc,%esp
f0101b0f:	6a 00                	push   $0x0
f0101b11:	e8 34 f5 ff ff       	call   f010104a <page_alloc>
f0101b16:	83 c4 10             	add    $0x10,%esp
f0101b19:	85 c0                	test   %eax,%eax
f0101b1b:	0f 85 6f 08 00 00    	jne    f0102390 <mem_init+0xeff>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b21:	83 ec 04             	sub    $0x4,%esp
f0101b24:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b27:	50                   	push   %eax
f0101b28:	6a 00                	push   $0x0
f0101b2a:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101b30:	ff 30                	pushl  (%eax)
f0101b32:	e8 29 f8 ff ff       	call   f0101360 <page_lookup>
f0101b37:	83 c4 10             	add    $0x10,%esp
f0101b3a:	85 c0                	test   %eax,%eax
f0101b3c:	0f 85 6d 08 00 00    	jne    f01023af <mem_init+0xf1e>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b42:	6a 02                	push   $0x2
f0101b44:	6a 00                	push   $0x0
f0101b46:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b49:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101b4f:	ff 30                	pushl  (%eax)
f0101b51:	e8 bd f8 ff ff       	call   f0101413 <page_insert>
f0101b56:	83 c4 10             	add    $0x10,%esp
f0101b59:	85 c0                	test   %eax,%eax
f0101b5b:	0f 89 6d 08 00 00    	jns    f01023ce <mem_init+0xf3d>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b61:	83 ec 0c             	sub    $0xc,%esp
f0101b64:	ff 75 cc             	pushl  -0x34(%ebp)
f0101b67:	e8 81 f5 ff ff       	call   f01010ed <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b6c:	6a 02                	push   $0x2
f0101b6e:	6a 00                	push   $0x0
f0101b70:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b73:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101b79:	ff 30                	pushl  (%eax)
f0101b7b:	e8 93 f8 ff ff       	call   f0101413 <page_insert>
f0101b80:	83 c4 20             	add    $0x20,%esp
f0101b83:	85 c0                	test   %eax,%eax
f0101b85:	0f 85 62 08 00 00    	jne    f01023ed <mem_init+0xf5c>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b8b:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101b91:	8b 30                	mov    (%eax),%esi
	return (pp - pages) << PGSHIFT;
f0101b93:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101b99:	8b 38                	mov    (%eax),%edi
f0101b9b:	8b 16                	mov    (%esi),%edx
f0101b9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ba3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ba6:	29 f8                	sub    %edi,%eax
f0101ba8:	c1 f8 03             	sar    $0x3,%eax
f0101bab:	c1 e0 0c             	shl    $0xc,%eax
f0101bae:	39 c2                	cmp    %eax,%edx
f0101bb0:	0f 85 56 08 00 00    	jne    f010240c <mem_init+0xf7b>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bb6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bbb:	89 f0                	mov    %esi,%eax
f0101bbd:	e8 a5 ef ff ff       	call   f0100b67 <check_va2pa>
f0101bc2:	89 c2                	mov    %eax,%edx
f0101bc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bc7:	29 f8                	sub    %edi,%eax
f0101bc9:	c1 f8 03             	sar    $0x3,%eax
f0101bcc:	c1 e0 0c             	shl    $0xc,%eax
f0101bcf:	39 c2                	cmp    %eax,%edx
f0101bd1:	0f 85 54 08 00 00    	jne    f010242b <mem_init+0xf9a>
	assert(pp1->pp_ref == 1);
f0101bd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bda:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bdf:	0f 85 65 08 00 00    	jne    f010244a <mem_init+0xfb9>
	assert(pp0->pp_ref == 1);
f0101be5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101be8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bed:	0f 85 76 08 00 00    	jne    f0102469 <mem_init+0xfd8>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bf3:	6a 02                	push   $0x2
f0101bf5:	68 00 10 00 00       	push   $0x1000
f0101bfa:	ff 75 d0             	pushl  -0x30(%ebp)
f0101bfd:	56                   	push   %esi
f0101bfe:	e8 10 f8 ff ff       	call   f0101413 <page_insert>
f0101c03:	83 c4 10             	add    $0x10,%esp
f0101c06:	85 c0                	test   %eax,%eax
f0101c08:	0f 85 7a 08 00 00    	jne    f0102488 <mem_init+0xff7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c0e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c13:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101c19:	8b 00                	mov    (%eax),%eax
f0101c1b:	e8 47 ef ff ff       	call   f0100b67 <check_va2pa>
f0101c20:	89 c2                	mov    %eax,%edx
f0101c22:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101c28:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101c2b:	2b 08                	sub    (%eax),%ecx
f0101c2d:	89 c8                	mov    %ecx,%eax
f0101c2f:	c1 f8 03             	sar    $0x3,%eax
f0101c32:	c1 e0 0c             	shl    $0xc,%eax
f0101c35:	39 c2                	cmp    %eax,%edx
f0101c37:	0f 85 6a 08 00 00    	jne    f01024a7 <mem_init+0x1016>
	assert(pp2->pp_ref == 1);
f0101c3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c40:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c45:	0f 85 7b 08 00 00    	jne    f01024c6 <mem_init+0x1035>

	// should be no free memory
	assert(!page_alloc(0));
f0101c4b:	83 ec 0c             	sub    $0xc,%esp
f0101c4e:	6a 00                	push   $0x0
f0101c50:	e8 f5 f3 ff ff       	call   f010104a <page_alloc>
f0101c55:	83 c4 10             	add    $0x10,%esp
f0101c58:	85 c0                	test   %eax,%eax
f0101c5a:	0f 85 85 08 00 00    	jne    f01024e5 <mem_init+0x1054>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c60:	6a 02                	push   $0x2
f0101c62:	68 00 10 00 00       	push   $0x1000
f0101c67:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c6a:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101c70:	ff 30                	pushl  (%eax)
f0101c72:	e8 9c f7 ff ff       	call   f0101413 <page_insert>
f0101c77:	83 c4 10             	add    $0x10,%esp
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	0f 85 82 08 00 00    	jne    f0102504 <mem_init+0x1073>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c82:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c87:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101c8d:	8b 00                	mov    (%eax),%eax
f0101c8f:	e8 d3 ee ff ff       	call   f0100b67 <check_va2pa>
f0101c94:	89 c2                	mov    %eax,%edx
f0101c96:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101c9c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101c9f:	2b 08                	sub    (%eax),%ecx
f0101ca1:	89 c8                	mov    %ecx,%eax
f0101ca3:	c1 f8 03             	sar    $0x3,%eax
f0101ca6:	c1 e0 0c             	shl    $0xc,%eax
f0101ca9:	39 c2                	cmp    %eax,%edx
f0101cab:	0f 85 72 08 00 00    	jne    f0102523 <mem_init+0x1092>
	assert(pp2->pp_ref == 1);
f0101cb1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cb4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cb9:	0f 85 83 08 00 00    	jne    f0102542 <mem_init+0x10b1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cbf:	83 ec 0c             	sub    $0xc,%esp
f0101cc2:	6a 00                	push   $0x0
f0101cc4:	e8 81 f3 ff ff       	call   f010104a <page_alloc>
f0101cc9:	83 c4 10             	add    $0x10,%esp
f0101ccc:	85 c0                	test   %eax,%eax
f0101cce:	0f 85 8d 08 00 00    	jne    f0102561 <mem_init+0x10d0>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cd4:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101cda:	8b 08                	mov    (%eax),%ecx
f0101cdc:	8b 01                	mov    (%ecx),%eax
f0101cde:	89 c2                	mov    %eax,%edx
f0101ce0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101ce6:	c1 e8 0c             	shr    $0xc,%eax
f0101ce9:	c7 c6 a8 a6 11 f0    	mov    $0xf011a6a8,%esi
f0101cef:	3b 06                	cmp    (%esi),%eax
f0101cf1:	0f 83 89 08 00 00    	jae    f0102580 <mem_init+0x10ef>
	return (void *)(pa + KERNBASE);
f0101cf7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101cfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d00:	83 ec 04             	sub    $0x4,%esp
f0101d03:	6a 00                	push   $0x0
f0101d05:	68 00 10 00 00       	push   $0x1000
f0101d0a:	51                   	push   %ecx
f0101d0b:	e8 78 f4 ff ff       	call   f0101188 <pgdir_walk>
f0101d10:	89 c2                	mov    %eax,%edx
f0101d12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d15:	83 c0 04             	add    $0x4,%eax
f0101d18:	83 c4 10             	add    $0x10,%esp
f0101d1b:	39 d0                	cmp    %edx,%eax
f0101d1d:	0f 85 76 08 00 00    	jne    f0102599 <mem_init+0x1108>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d23:	6a 06                	push   $0x6
f0101d25:	68 00 10 00 00       	push   $0x1000
f0101d2a:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d2d:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101d33:	ff 30                	pushl  (%eax)
f0101d35:	e8 d9 f6 ff ff       	call   f0101413 <page_insert>
f0101d3a:	83 c4 10             	add    $0x10,%esp
f0101d3d:	85 c0                	test   %eax,%eax
f0101d3f:	0f 85 73 08 00 00    	jne    f01025b8 <mem_init+0x1127>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d45:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101d4b:	8b 30                	mov    (%eax),%esi
f0101d4d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d52:	89 f0                	mov    %esi,%eax
f0101d54:	e8 0e ee ff ff       	call   f0100b67 <check_va2pa>
f0101d59:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101d5b:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101d61:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101d64:	2b 08                	sub    (%eax),%ecx
f0101d66:	89 c8                	mov    %ecx,%eax
f0101d68:	c1 f8 03             	sar    $0x3,%eax
f0101d6b:	c1 e0 0c             	shl    $0xc,%eax
f0101d6e:	39 c2                	cmp    %eax,%edx
f0101d70:	0f 85 61 08 00 00    	jne    f01025d7 <mem_init+0x1146>
	assert(pp2->pp_ref == 1);
f0101d76:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d79:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d7e:	0f 85 72 08 00 00    	jne    f01025f6 <mem_init+0x1165>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d84:	83 ec 04             	sub    $0x4,%esp
f0101d87:	6a 00                	push   $0x0
f0101d89:	68 00 10 00 00       	push   $0x1000
f0101d8e:	56                   	push   %esi
f0101d8f:	e8 f4 f3 ff ff       	call   f0101188 <pgdir_walk>
f0101d94:	83 c4 10             	add    $0x10,%esp
f0101d97:	f6 00 04             	testb  $0x4,(%eax)
f0101d9a:	0f 84 75 08 00 00    	je     f0102615 <mem_init+0x1184>
	assert(kern_pgdir[0] & PTE_U);
f0101da0:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101da6:	8b 00                	mov    (%eax),%eax
f0101da8:	f6 00 04             	testb  $0x4,(%eax)
f0101dab:	0f 84 83 08 00 00    	je     f0102634 <mem_init+0x11a3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101db1:	6a 02                	push   $0x2
f0101db3:	68 00 10 00 00       	push   $0x1000
f0101db8:	ff 75 d0             	pushl  -0x30(%ebp)
f0101dbb:	50                   	push   %eax
f0101dbc:	e8 52 f6 ff ff       	call   f0101413 <page_insert>
f0101dc1:	83 c4 10             	add    $0x10,%esp
f0101dc4:	85 c0                	test   %eax,%eax
f0101dc6:	0f 85 87 08 00 00    	jne    f0102653 <mem_init+0x11c2>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dcc:	83 ec 04             	sub    $0x4,%esp
f0101dcf:	6a 00                	push   $0x0
f0101dd1:	68 00 10 00 00       	push   $0x1000
f0101dd6:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101ddc:	ff 30                	pushl  (%eax)
f0101dde:	e8 a5 f3 ff ff       	call   f0101188 <pgdir_walk>
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	f6 00 02             	testb  $0x2,(%eax)
f0101de9:	0f 84 83 08 00 00    	je     f0102672 <mem_init+0x11e1>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101def:	83 ec 04             	sub    $0x4,%esp
f0101df2:	6a 00                	push   $0x0
f0101df4:	68 00 10 00 00       	push   $0x1000
f0101df9:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101dff:	ff 30                	pushl  (%eax)
f0101e01:	e8 82 f3 ff ff       	call   f0101188 <pgdir_walk>
f0101e06:	83 c4 10             	add    $0x10,%esp
f0101e09:	f6 00 04             	testb  $0x4,(%eax)
f0101e0c:	0f 85 7f 08 00 00    	jne    f0102691 <mem_init+0x1200>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e12:	6a 02                	push   $0x2
f0101e14:	68 00 00 40 00       	push   $0x400000
f0101e19:	ff 75 cc             	pushl  -0x34(%ebp)
f0101e1c:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101e22:	ff 30                	pushl  (%eax)
f0101e24:	e8 ea f5 ff ff       	call   f0101413 <page_insert>
f0101e29:	83 c4 10             	add    $0x10,%esp
f0101e2c:	85 c0                	test   %eax,%eax
f0101e2e:	0f 89 7c 08 00 00    	jns    f01026b0 <mem_init+0x121f>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e34:	6a 02                	push   $0x2
f0101e36:	68 00 10 00 00       	push   $0x1000
f0101e3b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e3e:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101e44:	ff 30                	pushl  (%eax)
f0101e46:	e8 c8 f5 ff ff       	call   f0101413 <page_insert>
f0101e4b:	83 c4 10             	add    $0x10,%esp
f0101e4e:	85 c0                	test   %eax,%eax
f0101e50:	0f 85 79 08 00 00    	jne    f01026cf <mem_init+0x123e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e56:	83 ec 04             	sub    $0x4,%esp
f0101e59:	6a 00                	push   $0x0
f0101e5b:	68 00 10 00 00       	push   $0x1000
f0101e60:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101e66:	ff 30                	pushl  (%eax)
f0101e68:	e8 1b f3 ff ff       	call   f0101188 <pgdir_walk>
f0101e6d:	83 c4 10             	add    $0x10,%esp
f0101e70:	f6 00 04             	testb  $0x4,(%eax)
f0101e73:	0f 85 75 08 00 00    	jne    f01026ee <mem_init+0x125d>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e79:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0101e7f:	8b 38                	mov    (%eax),%edi
f0101e81:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e86:	89 f8                	mov    %edi,%eax
f0101e88:	e8 da ec ff ff       	call   f0100b67 <check_va2pa>
f0101e8d:	c7 c2 b0 a6 11 f0    	mov    $0xf011a6b0,%edx
f0101e93:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e96:	2b 32                	sub    (%edx),%esi
f0101e98:	c1 fe 03             	sar    $0x3,%esi
f0101e9b:	c1 e6 0c             	shl    $0xc,%esi
f0101e9e:	39 f0                	cmp    %esi,%eax
f0101ea0:	0f 85 67 08 00 00    	jne    f010270d <mem_init+0x127c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ea6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eab:	89 f8                	mov    %edi,%eax
f0101ead:	e8 b5 ec ff ff       	call   f0100b67 <check_va2pa>
f0101eb2:	39 c6                	cmp    %eax,%esi
f0101eb4:	0f 85 72 08 00 00    	jne    f010272c <mem_init+0x129b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101eba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ebd:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101ec2:	0f 85 83 08 00 00    	jne    f010274b <mem_init+0x12ba>
	assert(pp2->pp_ref == 0);
f0101ec8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ecb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ed0:	0f 85 94 08 00 00    	jne    f010276a <mem_init+0x12d9>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ed6:	83 ec 0c             	sub    $0xc,%esp
f0101ed9:	6a 00                	push   $0x0
f0101edb:	e8 6a f1 ff ff       	call   f010104a <page_alloc>
f0101ee0:	83 c4 10             	add    $0x10,%esp
f0101ee3:	85 c0                	test   %eax,%eax
f0101ee5:	0f 84 9e 08 00 00    	je     f0102789 <mem_init+0x12f8>
f0101eeb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101eee:	0f 85 95 08 00 00    	jne    f0102789 <mem_init+0x12f8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ef4:	83 ec 08             	sub    $0x8,%esp
f0101ef7:	6a 00                	push   $0x0
f0101ef9:	c7 c6 ac a6 11 f0    	mov    $0xf011a6ac,%esi
f0101eff:	ff 36                	pushl  (%esi)
f0101f01:	e8 c7 f4 ff ff       	call   f01013cd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f06:	8b 36                	mov    (%esi),%esi
f0101f08:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f0d:	89 f0                	mov    %esi,%eax
f0101f0f:	e8 53 ec ff ff       	call   f0100b67 <check_va2pa>
f0101f14:	83 c4 10             	add    $0x10,%esp
f0101f17:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f1a:	0f 85 88 08 00 00    	jne    f01027a8 <mem_init+0x1317>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f25:	89 f0                	mov    %esi,%eax
f0101f27:	e8 3b ec ff ff       	call   f0100b67 <check_va2pa>
f0101f2c:	89 c2                	mov    %eax,%edx
f0101f2e:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0101f34:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f37:	2b 08                	sub    (%eax),%ecx
f0101f39:	89 c8                	mov    %ecx,%eax
f0101f3b:	c1 f8 03             	sar    $0x3,%eax
f0101f3e:	c1 e0 0c             	shl    $0xc,%eax
f0101f41:	39 c2                	cmp    %eax,%edx
f0101f43:	0f 85 7e 08 00 00    	jne    f01027c7 <mem_init+0x1336>
	assert(pp1->pp_ref == 1);
f0101f49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f4c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f51:	0f 85 8f 08 00 00    	jne    f01027e6 <mem_init+0x1355>
	assert(pp2->pp_ref == 0);
f0101f57:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f5a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f5f:	0f 85 a0 08 00 00    	jne    f0102805 <mem_init+0x1374>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f65:	6a 00                	push   $0x0
f0101f67:	68 00 10 00 00       	push   $0x1000
f0101f6c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f6f:	56                   	push   %esi
f0101f70:	e8 9e f4 ff ff       	call   f0101413 <page_insert>
f0101f75:	83 c4 10             	add    $0x10,%esp
f0101f78:	85 c0                	test   %eax,%eax
f0101f7a:	0f 85 a4 08 00 00    	jne    f0102824 <mem_init+0x1393>
	assert(pp1->pp_ref);
f0101f80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f83:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f88:	0f 84 b5 08 00 00    	je     f0102843 <mem_init+0x13b2>
	assert(pp1->pp_link == NULL);
f0101f8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f91:	83 38 00             	cmpl   $0x0,(%eax)
f0101f94:	0f 85 c8 08 00 00    	jne    f0102862 <mem_init+0x13d1>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f9a:	83 ec 08             	sub    $0x8,%esp
f0101f9d:	68 00 10 00 00       	push   $0x1000
f0101fa2:	c7 c6 ac a6 11 f0    	mov    $0xf011a6ac,%esi
f0101fa8:	ff 36                	pushl  (%esi)
f0101faa:	e8 1e f4 ff ff       	call   f01013cd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101faf:	8b 36                	mov    (%esi),%esi
f0101fb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fb6:	89 f0                	mov    %esi,%eax
f0101fb8:	e8 aa eb ff ff       	call   f0100b67 <check_va2pa>
f0101fbd:	83 c4 10             	add    $0x10,%esp
f0101fc0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fc3:	0f 85 b8 08 00 00    	jne    f0102881 <mem_init+0x13f0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fc9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fce:	89 f0                	mov    %esi,%eax
f0101fd0:	e8 92 eb ff ff       	call   f0100b67 <check_va2pa>
f0101fd5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fd8:	0f 85 c2 08 00 00    	jne    f01028a0 <mem_init+0x140f>
	assert(pp1->pp_ref == 0);
f0101fde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101fe6:	0f 85 d3 08 00 00    	jne    f01028bf <mem_init+0x142e>
	assert(pp2->pp_ref == 0);
f0101fec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101fef:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ff4:	0f 85 e4 08 00 00    	jne    f01028de <mem_init+0x144d>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ffa:	83 ec 0c             	sub    $0xc,%esp
f0101ffd:	6a 00                	push   $0x0
f0101fff:	e8 46 f0 ff ff       	call   f010104a <page_alloc>
f0102004:	83 c4 10             	add    $0x10,%esp
f0102007:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010200a:	0f 85 ed 08 00 00    	jne    f01028fd <mem_init+0x146c>
f0102010:	85 c0                	test   %eax,%eax
f0102012:	0f 84 e5 08 00 00    	je     f01028fd <mem_init+0x146c>

	// should be no free memory
	assert(!page_alloc(0));
f0102018:	83 ec 0c             	sub    $0xc,%esp
f010201b:	6a 00                	push   $0x0
f010201d:	e8 28 f0 ff ff       	call   f010104a <page_alloc>
f0102022:	83 c4 10             	add    $0x10,%esp
f0102025:	85 c0                	test   %eax,%eax
f0102027:	0f 85 ef 08 00 00    	jne    f010291c <mem_init+0x148b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010202d:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102033:	8b 08                	mov    (%eax),%ecx
f0102035:	8b 11                	mov    (%ecx),%edx
f0102037:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010203d:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102043:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102046:	2b 38                	sub    (%eax),%edi
f0102048:	89 f8                	mov    %edi,%eax
f010204a:	c1 f8 03             	sar    $0x3,%eax
f010204d:	c1 e0 0c             	shl    $0xc,%eax
f0102050:	39 c2                	cmp    %eax,%edx
f0102052:	0f 85 e3 08 00 00    	jne    f010293b <mem_init+0x14aa>
	kern_pgdir[0] = 0;
f0102058:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010205e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102061:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102066:	0f 85 ee 08 00 00    	jne    f010295a <mem_init+0x14c9>
	pp0->pp_ref = 0;
f010206c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010206f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102075:	83 ec 0c             	sub    $0xc,%esp
f0102078:	50                   	push   %eax
f0102079:	e8 6f f0 ff ff       	call   f01010ed <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010207e:	83 c4 0c             	add    $0xc,%esp
f0102081:	6a 01                	push   $0x1
f0102083:	68 00 10 40 00       	push   $0x401000
f0102088:	c7 c6 ac a6 11 f0    	mov    $0xf011a6ac,%esi
f010208e:	ff 36                	pushl  (%esi)
f0102090:	e8 f3 f0 ff ff       	call   f0101188 <pgdir_walk>
f0102095:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102098:	8b 3e                	mov    (%esi),%edi
f010209a:	8b 57 04             	mov    0x4(%edi),%edx
f010209d:	89 d1                	mov    %edx,%ecx
f010209f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f01020a5:	c7 c6 a8 a6 11 f0    	mov    $0xf011a6a8,%esi
f01020ab:	8b 36                	mov    (%esi),%esi
f01020ad:	c1 ea 0c             	shr    $0xc,%edx
f01020b0:	83 c4 10             	add    $0x10,%esp
f01020b3:	39 f2                	cmp    %esi,%edx
f01020b5:	0f 83 be 08 00 00    	jae    f0102979 <mem_init+0x14e8>
	assert(ptep == ptep1 + PTX(va));
f01020bb:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f01020c1:	39 c8                	cmp    %ecx,%eax
f01020c3:	0f 85 c9 08 00 00    	jne    f0102992 <mem_init+0x1501>
	kern_pgdir[PDX(va)] = 0;
f01020c9:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	pp0->pp_ref = 0;
f01020d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01020d3:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
	return (pp - pages) << PGSHIFT;
f01020d9:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f01020df:	2b 08                	sub    (%eax),%ecx
f01020e1:	89 c8                	mov    %ecx,%eax
f01020e3:	c1 f8 03             	sar    $0x3,%eax
f01020e6:	89 c2                	mov    %eax,%edx
f01020e8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020eb:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01020f0:	39 c6                	cmp    %eax,%esi
f01020f2:	0f 86 b9 08 00 00    	jbe    f01029b1 <mem_init+0x1520>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020f8:	83 ec 04             	sub    $0x4,%esp
f01020fb:	68 00 10 00 00       	push   $0x1000
f0102100:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102105:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010210b:	52                   	push   %edx
f010210c:	e8 26 1c 00 00       	call   f0103d37 <memset>
	page_free(pp0);
f0102111:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102114:	89 3c 24             	mov    %edi,(%esp)
f0102117:	e8 d1 ef ff ff       	call   f01010ed <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010211c:	83 c4 0c             	add    $0xc,%esp
f010211f:	6a 01                	push   $0x1
f0102121:	6a 00                	push   $0x0
f0102123:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102129:	ff 30                	pushl  (%eax)
f010212b:	e8 58 f0 ff ff       	call   f0101188 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102130:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102136:	2b 38                	sub    (%eax),%edi
f0102138:	89 f8                	mov    %edi,%eax
f010213a:	c1 f8 03             	sar    $0x3,%eax
f010213d:	89 c2                	mov    %eax,%edx
f010213f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102142:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102147:	83 c4 10             	add    $0x10,%esp
f010214a:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0102150:	3b 01                	cmp    (%ecx),%eax
f0102152:	0f 83 6f 08 00 00    	jae    f01029c7 <mem_init+0x1536>
	return (void *)(pa + KERNBASE);
f0102158:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010215e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102161:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102167:	8b 38                	mov    (%eax),%edi
f0102169:	83 e7 01             	and    $0x1,%edi
f010216c:	0f 85 6b 08 00 00    	jne    f01029dd <mem_init+0x154c>
f0102172:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102175:	39 d0                	cmp    %edx,%eax
f0102177:	75 ee                	jne    f0102167 <mem_init+0xcd6>
	kern_pgdir[0] = 0;
f0102179:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f010217f:	8b 00                	mov    (%eax),%eax
f0102181:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102187:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010218a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102190:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102193:	89 8b 94 1f 00 00    	mov    %ecx,0x1f94(%ebx)

	// free the pages we took
	page_free(pp0);
f0102199:	83 ec 0c             	sub    $0xc,%esp
f010219c:	50                   	push   %eax
f010219d:	e8 4b ef ff ff       	call   f01010ed <page_free>
	page_free(pp1);
f01021a2:	83 c4 04             	add    $0x4,%esp
f01021a5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021a8:	e8 40 ef ff ff       	call   f01010ed <page_free>
	page_free(pp2);
f01021ad:	83 c4 04             	add    $0x4,%esp
f01021b0:	ff 75 d0             	pushl  -0x30(%ebp)
f01021b3:	e8 35 ef ff ff       	call   f01010ed <page_free>

	cprintf("check_page() succeeded!\n");
f01021b8:	8d 83 5a ce fe ff    	lea    -0x131a6(%ebx),%eax
f01021be:	89 04 24             	mov    %eax,(%esp)
f01021c1:	e8 0c 0f 00 00       	call   f01030d2 <cprintf>
	boot_map_region(kern_pgdir, 
f01021c6:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f01021cc:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01021ce:	83 c4 10             	add    $0x10,%esp
f01021d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021d6:	0f 86 20 08 00 00    	jbe    f01029fc <mem_init+0x156b>
                    ROUNDUP((sizeof(struct PageInfo)*npages), PGSIZE),
f01021dc:	c7 c2 a8 a6 11 f0    	mov    $0xf011a6a8,%edx
f01021e2:	8b 12                	mov    (%edx),%edx
f01021e4:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	boot_map_region(kern_pgdir, 
f01021eb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01021f1:	83 ec 08             	sub    $0x8,%esp
f01021f4:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021f6:	05 00 00 00 10       	add    $0x10000000,%eax
f01021fb:	50                   	push   %eax
f01021fc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102201:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102207:	8b 00                	mov    (%eax),%eax
f0102209:	e8 71 f0 ff ff       	call   f010127f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010220e:	c7 c0 00 f0 10 f0    	mov    $0xf010f000,%eax
f0102214:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102217:	83 c4 10             	add    $0x10,%esp
f010221a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010221f:	0f 86 f0 07 00 00    	jbe    f0102a15 <mem_init+0x1584>
	boot_map_region(kern_pgdir, 
f0102225:	c7 c6 ac a6 11 f0    	mov    $0xf011a6ac,%esi
f010222b:	83 ec 08             	sub    $0x8,%esp
f010222e:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102230:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102233:	05 00 00 00 10       	add    $0x10000000,%eax
f0102238:	50                   	push   %eax
f0102239:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010223e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102243:	8b 06                	mov    (%esi),%eax
f0102245:	e8 35 f0 ff ff       	call   f010127f <boot_map_region>
	boot_map_region(kern_pgdir, 
f010224a:	83 c4 08             	add    $0x8,%esp
f010224d:	6a 03                	push   $0x3
f010224f:	6a 00                	push   $0x0
f0102251:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102256:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010225b:	8b 06                	mov    (%esi),%eax
f010225d:	e8 1d f0 ff ff       	call   f010127f <boot_map_region>
	pgdir = kern_pgdir;
f0102262:	8b 06                	mov    (%esi),%eax
f0102264:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102267:	c7 c0 a8 a6 11 f0    	mov    $0xf011a6a8,%eax
f010226d:	8b 00                	mov    (%eax),%eax
f010226f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102272:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102279:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010227e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102281:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102287:	8b 00                	mov    (%eax),%eax
f0102289:	89 45 bc             	mov    %eax,-0x44(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010228c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010228f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102294:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102297:	83 c4 10             	add    $0x10,%esp
f010229a:	89 fe                	mov    %edi,%esi
f010229c:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f010229f:	0f 86 c3 07 00 00    	jbe    f0102a68 <mem_init+0x15d7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a5:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01022ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022ae:	e8 b4 e8 ff ff       	call   f0100b67 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01022b3:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01022ba:	0f 86 6e 07 00 00    	jbe    f0102a2e <mem_init+0x159d>
f01022c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01022c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01022c6:	39 d0                	cmp    %edx,%eax
f01022c8:	0f 85 7b 07 00 00    	jne    f0102a49 <mem_init+0x15b8>
	for (i = 0; i < n; i += PGSIZE)
f01022ce:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01022d4:	eb c6                	jmp    f010229c <mem_init+0xe0b>
	assert(nfree == 0);
f01022d6:	8d 83 83 cd fe ff    	lea    -0x1327d(%ebx),%eax
f01022dc:	50                   	push   %eax
f01022dd:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01022e3:	50                   	push   %eax
f01022e4:	68 b0 02 00 00       	push   $0x2b0
f01022e9:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01022ef:	50                   	push   %eax
f01022f0:	e8 2d de ff ff       	call   f0100122 <_panic>
	assert((pp0 = page_alloc(0)));
f01022f5:	8d 83 91 cc fe ff    	lea    -0x1336f(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102302:	50                   	push   %eax
f0102303:	68 09 03 00 00       	push   $0x309
f0102308:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	e8 0e de ff ff       	call   f0100122 <_panic>
	assert((pp1 = page_alloc(0)));
f0102314:	8d 83 a7 cc fe ff    	lea    -0x13359(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102321:	50                   	push   %eax
f0102322:	68 0a 03 00 00       	push   $0x30a
f0102327:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010232d:	50                   	push   %eax
f010232e:	e8 ef dd ff ff       	call   f0100122 <_panic>
	assert((pp2 = page_alloc(0)));
f0102333:	8d 83 bd cc fe ff    	lea    -0x13343(%ebx),%eax
f0102339:	50                   	push   %eax
f010233a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102340:	50                   	push   %eax
f0102341:	68 0b 03 00 00       	push   $0x30b
f0102346:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010234c:	50                   	push   %eax
f010234d:	e8 d0 dd ff ff       	call   f0100122 <_panic>
	assert(pp1 && pp1 != pp0);
f0102352:	8d 83 d3 cc fe ff    	lea    -0x1332d(%ebx),%eax
f0102358:	50                   	push   %eax
f0102359:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010235f:	50                   	push   %eax
f0102360:	68 0e 03 00 00       	push   $0x30e
f0102365:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010236b:	50                   	push   %eax
f010236c:	e8 b1 dd ff ff       	call   f0100122 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102371:	8d 83 60 c5 fe ff    	lea    -0x13aa0(%ebx),%eax
f0102377:	50                   	push   %eax
f0102378:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010237e:	50                   	push   %eax
f010237f:	68 0f 03 00 00       	push   $0x30f
f0102384:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010238a:	50                   	push   %eax
f010238b:	e8 92 dd ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f0102390:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010239d:	50                   	push   %eax
f010239e:	68 16 03 00 00       	push   $0x316
f01023a3:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01023a9:	50                   	push   %eax
f01023aa:	e8 73 dd ff ff       	call   f0100122 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01023af:	8d 83 a0 c5 fe ff    	lea    -0x13a60(%ebx),%eax
f01023b5:	50                   	push   %eax
f01023b6:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01023bc:	50                   	push   %eax
f01023bd:	68 19 03 00 00       	push   $0x319
f01023c2:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01023c8:	50                   	push   %eax
f01023c9:	e8 54 dd ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023ce:	8d 83 d8 c5 fe ff    	lea    -0x13a28(%ebx),%eax
f01023d4:	50                   	push   %eax
f01023d5:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01023db:	50                   	push   %eax
f01023dc:	68 1c 03 00 00       	push   $0x31c
f01023e1:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01023e7:	50                   	push   %eax
f01023e8:	e8 35 dd ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023ed:	8d 83 08 c6 fe ff    	lea    -0x139f8(%ebx),%eax
f01023f3:	50                   	push   %eax
f01023f4:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01023fa:	50                   	push   %eax
f01023fb:	68 20 03 00 00       	push   $0x320
f0102400:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102406:	50                   	push   %eax
f0102407:	e8 16 dd ff ff       	call   f0100122 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010240c:	8d 83 38 c6 fe ff    	lea    -0x139c8(%ebx),%eax
f0102412:	50                   	push   %eax
f0102413:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102419:	50                   	push   %eax
f010241a:	68 21 03 00 00       	push   $0x321
f010241f:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102425:	50                   	push   %eax
f0102426:	e8 f7 dc ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010242b:	8d 83 60 c6 fe ff    	lea    -0x139a0(%ebx),%eax
f0102431:	50                   	push   %eax
f0102432:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102438:	50                   	push   %eax
f0102439:	68 22 03 00 00       	push   $0x322
f010243e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102444:	50                   	push   %eax
f0102445:	e8 d8 dc ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 1);
f010244a:	8d 83 8e cd fe ff    	lea    -0x13272(%ebx),%eax
f0102450:	50                   	push   %eax
f0102451:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102457:	50                   	push   %eax
f0102458:	68 23 03 00 00       	push   $0x323
f010245d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102463:	50                   	push   %eax
f0102464:	e8 b9 dc ff ff       	call   f0100122 <_panic>
	assert(pp0->pp_ref == 1);
f0102469:	8d 83 9f cd fe ff    	lea    -0x13261(%ebx),%eax
f010246f:	50                   	push   %eax
f0102470:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102476:	50                   	push   %eax
f0102477:	68 24 03 00 00       	push   $0x324
f010247c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102482:	50                   	push   %eax
f0102483:	e8 9a dc ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102488:	8d 83 90 c6 fe ff    	lea    -0x13970(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102495:	50                   	push   %eax
f0102496:	68 27 03 00 00       	push   $0x327
f010249b:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	e8 7b dc ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024a7:	8d 83 cc c6 fe ff    	lea    -0x13934(%ebx),%eax
f01024ad:	50                   	push   %eax
f01024ae:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	68 28 03 00 00       	push   $0x328
f01024ba:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01024c0:	50                   	push   %eax
f01024c1:	e8 5c dc ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 1);
f01024c6:	8d 83 b0 cd fe ff    	lea    -0x13250(%ebx),%eax
f01024cc:	50                   	push   %eax
f01024cd:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01024d3:	50                   	push   %eax
f01024d4:	68 29 03 00 00       	push   $0x329
f01024d9:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01024df:	50                   	push   %eax
f01024e0:	e8 3d dc ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f01024e5:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f01024eb:	50                   	push   %eax
f01024ec:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01024f2:	50                   	push   %eax
f01024f3:	68 2c 03 00 00       	push   $0x32c
f01024f8:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	e8 1e dc ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102504:	8d 83 90 c6 fe ff    	lea    -0x13970(%ebx),%eax
f010250a:	50                   	push   %eax
f010250b:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	68 2f 03 00 00       	push   $0x32f
f0102517:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010251d:	50                   	push   %eax
f010251e:	e8 ff db ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102523:	8d 83 cc c6 fe ff    	lea    -0x13934(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102530:	50                   	push   %eax
f0102531:	68 30 03 00 00       	push   $0x330
f0102536:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	e8 e0 db ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 1);
f0102542:	8d 83 b0 cd fe ff    	lea    -0x13250(%ebx),%eax
f0102548:	50                   	push   %eax
f0102549:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010254f:	50                   	push   %eax
f0102550:	68 31 03 00 00       	push   $0x331
f0102555:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010255b:	50                   	push   %eax
f010255c:	e8 c1 db ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f0102561:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f0102567:	50                   	push   %eax
f0102568:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010256e:	50                   	push   %eax
f010256f:	68 35 03 00 00       	push   $0x335
f0102574:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	e8 a2 db ff ff       	call   f0100122 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102580:	52                   	push   %edx
f0102581:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0102587:	50                   	push   %eax
f0102588:	68 38 03 00 00       	push   $0x338
f010258d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102593:	50                   	push   %eax
f0102594:	e8 89 db ff ff       	call   f0100122 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102599:	8d 83 fc c6 fe ff    	lea    -0x13904(%ebx),%eax
f010259f:	50                   	push   %eax
f01025a0:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01025a6:	50                   	push   %eax
f01025a7:	68 39 03 00 00       	push   $0x339
f01025ac:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01025b2:	50                   	push   %eax
f01025b3:	e8 6a db ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025b8:	8d 83 3c c7 fe ff    	lea    -0x138c4(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01025c5:	50                   	push   %eax
f01025c6:	68 3c 03 00 00       	push   $0x33c
f01025cb:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	e8 4b db ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025d7:	8d 83 cc c6 fe ff    	lea    -0x13934(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01025e4:	50                   	push   %eax
f01025e5:	68 3d 03 00 00       	push   $0x33d
f01025ea:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01025f0:	50                   	push   %eax
f01025f1:	e8 2c db ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 1);
f01025f6:	8d 83 b0 cd fe ff    	lea    -0x13250(%ebx),%eax
f01025fc:	50                   	push   %eax
f01025fd:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102603:	50                   	push   %eax
f0102604:	68 3e 03 00 00       	push   $0x33e
f0102609:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010260f:	50                   	push   %eax
f0102610:	e8 0d db ff ff       	call   f0100122 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102615:	8d 83 7c c7 fe ff    	lea    -0x13884(%ebx),%eax
f010261b:	50                   	push   %eax
f010261c:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102622:	50                   	push   %eax
f0102623:	68 3f 03 00 00       	push   $0x33f
f0102628:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010262e:	50                   	push   %eax
f010262f:	e8 ee da ff ff       	call   f0100122 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102634:	8d 83 c1 cd fe ff    	lea    -0x1323f(%ebx),%eax
f010263a:	50                   	push   %eax
f010263b:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102641:	50                   	push   %eax
f0102642:	68 40 03 00 00       	push   $0x340
f0102647:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010264d:	50                   	push   %eax
f010264e:	e8 cf da ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102653:	8d 83 90 c6 fe ff    	lea    -0x13970(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102660:	50                   	push   %eax
f0102661:	68 43 03 00 00       	push   $0x343
f0102666:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010266c:	50                   	push   %eax
f010266d:	e8 b0 da ff ff       	call   f0100122 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102672:	8d 83 b0 c7 fe ff    	lea    -0x13850(%ebx),%eax
f0102678:	50                   	push   %eax
f0102679:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010267f:	50                   	push   %eax
f0102680:	68 44 03 00 00       	push   $0x344
f0102685:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010268b:	50                   	push   %eax
f010268c:	e8 91 da ff ff       	call   f0100122 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102691:	8d 83 e4 c7 fe ff    	lea    -0x1381c(%ebx),%eax
f0102697:	50                   	push   %eax
f0102698:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010269e:	50                   	push   %eax
f010269f:	68 45 03 00 00       	push   $0x345
f01026a4:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01026aa:	50                   	push   %eax
f01026ab:	e8 72 da ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026b0:	8d 83 1c c8 fe ff    	lea    -0x137e4(%ebx),%eax
f01026b6:	50                   	push   %eax
f01026b7:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01026bd:	50                   	push   %eax
f01026be:	68 48 03 00 00       	push   $0x348
f01026c3:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01026c9:	50                   	push   %eax
f01026ca:	e8 53 da ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026cf:	8d 83 54 c8 fe ff    	lea    -0x137ac(%ebx),%eax
f01026d5:	50                   	push   %eax
f01026d6:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01026dc:	50                   	push   %eax
f01026dd:	68 4b 03 00 00       	push   $0x34b
f01026e2:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01026e8:	50                   	push   %eax
f01026e9:	e8 34 da ff ff       	call   f0100122 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026ee:	8d 83 e4 c7 fe ff    	lea    -0x1381c(%ebx),%eax
f01026f4:	50                   	push   %eax
f01026f5:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	68 4c 03 00 00       	push   $0x34c
f0102701:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102707:	50                   	push   %eax
f0102708:	e8 15 da ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010270d:	8d 83 90 c8 fe ff    	lea    -0x13770(%ebx),%eax
f0102713:	50                   	push   %eax
f0102714:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010271a:	50                   	push   %eax
f010271b:	68 4f 03 00 00       	push   $0x34f
f0102720:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102726:	50                   	push   %eax
f0102727:	e8 f6 d9 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010272c:	8d 83 bc c8 fe ff    	lea    -0x13744(%ebx),%eax
f0102732:	50                   	push   %eax
f0102733:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102739:	50                   	push   %eax
f010273a:	68 50 03 00 00       	push   $0x350
f010273f:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102745:	50                   	push   %eax
f0102746:	e8 d7 d9 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 2);
f010274b:	8d 83 d7 cd fe ff    	lea    -0x13229(%ebx),%eax
f0102751:	50                   	push   %eax
f0102752:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102758:	50                   	push   %eax
f0102759:	68 52 03 00 00       	push   $0x352
f010275e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102764:	50                   	push   %eax
f0102765:	e8 b8 d9 ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 0);
f010276a:	8d 83 e8 cd fe ff    	lea    -0x13218(%ebx),%eax
f0102770:	50                   	push   %eax
f0102771:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102777:	50                   	push   %eax
f0102778:	68 53 03 00 00       	push   $0x353
f010277d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	e8 99 d9 ff ff       	call   f0100122 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102789:	8d 83 ec c8 fe ff    	lea    -0x13714(%ebx),%eax
f010278f:	50                   	push   %eax
f0102790:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	68 56 03 00 00       	push   $0x356
f010279c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01027a2:	50                   	push   %eax
f01027a3:	e8 7a d9 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027a8:	8d 83 10 c9 fe ff    	lea    -0x136f0(%ebx),%eax
f01027ae:	50                   	push   %eax
f01027af:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01027b5:	50                   	push   %eax
f01027b6:	68 5a 03 00 00       	push   $0x35a
f01027bb:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01027c1:	50                   	push   %eax
f01027c2:	e8 5b d9 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027c7:	8d 83 bc c8 fe ff    	lea    -0x13744(%ebx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01027d4:	50                   	push   %eax
f01027d5:	68 5b 03 00 00       	push   $0x35b
f01027da:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01027e0:	50                   	push   %eax
f01027e1:	e8 3c d9 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 1);
f01027e6:	8d 83 8e cd fe ff    	lea    -0x13272(%ebx),%eax
f01027ec:	50                   	push   %eax
f01027ed:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01027f3:	50                   	push   %eax
f01027f4:	68 5c 03 00 00       	push   $0x35c
f01027f9:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01027ff:	50                   	push   %eax
f0102800:	e8 1d d9 ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 0);
f0102805:	8d 83 e8 cd fe ff    	lea    -0x13218(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	68 5d 03 00 00       	push   $0x35d
f0102818:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	e8 fe d8 ff ff       	call   f0100122 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102824:	8d 83 34 c9 fe ff    	lea    -0x136cc(%ebx),%eax
f010282a:	50                   	push   %eax
f010282b:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	68 60 03 00 00       	push   $0x360
f0102837:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010283d:	50                   	push   %eax
f010283e:	e8 df d8 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref);
f0102843:	8d 83 f9 cd fe ff    	lea    -0x13207(%ebx),%eax
f0102849:	50                   	push   %eax
f010284a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102850:	50                   	push   %eax
f0102851:	68 61 03 00 00       	push   $0x361
f0102856:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010285c:	50                   	push   %eax
f010285d:	e8 c0 d8 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_link == NULL);
f0102862:	8d 83 05 ce fe ff    	lea    -0x131fb(%ebx),%eax
f0102868:	50                   	push   %eax
f0102869:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010286f:	50                   	push   %eax
f0102870:	68 62 03 00 00       	push   $0x362
f0102875:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010287b:	50                   	push   %eax
f010287c:	e8 a1 d8 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102881:	8d 83 10 c9 fe ff    	lea    -0x136f0(%ebx),%eax
f0102887:	50                   	push   %eax
f0102888:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010288e:	50                   	push   %eax
f010288f:	68 66 03 00 00       	push   $0x366
f0102894:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	e8 82 d8 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028a0:	8d 83 6c c9 fe ff    	lea    -0x13694(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01028ad:	50                   	push   %eax
f01028ae:	68 67 03 00 00       	push   $0x367
f01028b3:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	e8 63 d8 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 0);
f01028bf:	8d 83 1a ce fe ff    	lea    -0x131e6(%ebx),%eax
f01028c5:	50                   	push   %eax
f01028c6:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	68 68 03 00 00       	push   $0x368
f01028d2:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	e8 44 d8 ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 0);
f01028de:	8d 83 e8 cd fe ff    	lea    -0x13218(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01028eb:	50                   	push   %eax
f01028ec:	68 69 03 00 00       	push   $0x369
f01028f1:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	e8 25 d8 ff ff       	call   f0100122 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01028fd:	8d 83 94 c9 fe ff    	lea    -0x1366c(%ebx),%eax
f0102903:	50                   	push   %eax
f0102904:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010290a:	50                   	push   %eax
f010290b:	68 6c 03 00 00       	push   $0x36c
f0102910:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102916:	50                   	push   %eax
f0102917:	e8 06 d8 ff ff       	call   f0100122 <_panic>
	assert(!page_alloc(0));
f010291c:	8d 83 3c cd fe ff    	lea    -0x132c4(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102929:	50                   	push   %eax
f010292a:	68 6f 03 00 00       	push   $0x36f
f010292f:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102935:	50                   	push   %eax
f0102936:	e8 e7 d7 ff ff       	call   f0100122 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010293b:	8d 83 38 c6 fe ff    	lea    -0x139c8(%ebx),%eax
f0102941:	50                   	push   %eax
f0102942:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	68 72 03 00 00       	push   $0x372
f010294e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	e8 c8 d7 ff ff       	call   f0100122 <_panic>
	assert(pp0->pp_ref == 1);
f010295a:	8d 83 9f cd fe ff    	lea    -0x13261(%ebx),%eax
f0102960:	50                   	push   %eax
f0102961:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102967:	50                   	push   %eax
f0102968:	68 74 03 00 00       	push   $0x374
f010296d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	e8 a9 d7 ff ff       	call   f0100122 <_panic>
f0102979:	51                   	push   %ecx
f010297a:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0102980:	50                   	push   %eax
f0102981:	68 7b 03 00 00       	push   $0x37b
f0102986:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010298c:	50                   	push   %eax
f010298d:	e8 90 d7 ff ff       	call   f0100122 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102992:	8d 83 2b ce fe ff    	lea    -0x131d5(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010299f:	50                   	push   %eax
f01029a0:	68 7c 03 00 00       	push   $0x37c
f01029a5:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01029ab:	50                   	push   %eax
f01029ac:	e8 71 d7 ff ff       	call   f0100122 <_panic>
f01029b1:	52                   	push   %edx
f01029b2:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f01029b8:	50                   	push   %eax
f01029b9:	6a 52                	push   $0x52
f01029bb:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f01029c1:	50                   	push   %eax
f01029c2:	e8 5b d7 ff ff       	call   f0100122 <_panic>
f01029c7:	52                   	push   %edx
f01029c8:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f01029ce:	50                   	push   %eax
f01029cf:	6a 52                	push   $0x52
f01029d1:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f01029d7:	50                   	push   %eax
f01029d8:	e8 45 d7 ff ff       	call   f0100122 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01029dd:	8d 83 43 ce fe ff    	lea    -0x131bd(%ebx),%eax
f01029e3:	50                   	push   %eax
f01029e4:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f01029ea:	50                   	push   %eax
f01029eb:	68 86 03 00 00       	push   $0x386
f01029f0:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f01029f6:	50                   	push   %eax
f01029f7:	e8 26 d7 ff ff       	call   f0100122 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029fc:	50                   	push   %eax
f01029fd:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f0102a03:	50                   	push   %eax
f0102a04:	68 b5 00 00 00       	push   $0xb5
f0102a09:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102a0f:	50                   	push   %eax
f0102a10:	e8 0d d7 ff ff       	call   f0100122 <_panic>
f0102a15:	50                   	push   %eax
f0102a16:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f0102a1c:	50                   	push   %eax
f0102a1d:	68 c5 00 00 00       	push   $0xc5
f0102a22:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102a28:	50                   	push   %eax
f0102a29:	e8 f4 d6 ff ff       	call   f0100122 <_panic>
f0102a2e:	ff 75 bc             	pushl  -0x44(%ebp)
f0102a31:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f0102a37:	50                   	push   %eax
f0102a38:	68 c8 02 00 00       	push   $0x2c8
f0102a3d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102a43:	50                   	push   %eax
f0102a44:	e8 d9 d6 ff ff       	call   f0100122 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a49:	8d 83 b8 c9 fe ff    	lea    -0x13648(%ebx),%eax
f0102a4f:	50                   	push   %eax
f0102a50:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102a56:	50                   	push   %eax
f0102a57:	68 c8 02 00 00       	push   $0x2c8
f0102a5c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102a62:	50                   	push   %eax
f0102a63:	e8 ba d6 ff ff       	call   f0100122 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a68:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0102a6b:	c1 e0 0c             	shl    $0xc,%eax
f0102a6e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a71:	89 fe                	mov    %edi,%esi
f0102a73:	3b 75 cc             	cmp    -0x34(%ebp),%esi
f0102a76:	73 39                	jae    f0102ab1 <mem_init+0x1620>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a78:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102a7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a81:	e8 e1 e0 ff ff       	call   f0100b67 <check_va2pa>
f0102a86:	39 c6                	cmp    %eax,%esi
f0102a88:	75 08                	jne    f0102a92 <mem_init+0x1601>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a8a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a90:	eb e1                	jmp    f0102a73 <mem_init+0x15e2>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a92:	8d 83 ec c9 fe ff    	lea    -0x13614(%ebx),%eax
f0102a98:	50                   	push   %eax
f0102a99:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102a9f:	50                   	push   %eax
f0102aa0:	68 cd 02 00 00       	push   $0x2cd
f0102aa5:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102aab:	50                   	push   %eax
f0102aac:	e8 71 d6 ff ff       	call   f0100122 <_panic>
f0102ab1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ab6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ab9:	05 00 80 00 20       	add    $0x20008000,%eax
f0102abe:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102ac1:	89 f2                	mov    %esi,%edx
f0102ac3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ac6:	e8 9c e0 ff ff       	call   f0100b67 <check_va2pa>
f0102acb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102ace:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0102ad1:	39 c2                	cmp    %eax,%edx
f0102ad3:	75 25                	jne    f0102afa <mem_init+0x1669>
f0102ad5:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102adb:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102ae1:	75 de                	jne    f0102ac1 <mem_init+0x1630>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ae3:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102ae8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102aeb:	e8 77 e0 ff ff       	call   f0100b67 <check_va2pa>
f0102af0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102af3:	75 24                	jne    f0102b19 <mem_init+0x1688>
f0102af5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102af8:	eb 6b                	jmp    f0102b65 <mem_init+0x16d4>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102afa:	8d 83 14 ca fe ff    	lea    -0x135ec(%ebx),%eax
f0102b00:	50                   	push   %eax
f0102b01:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102b07:	50                   	push   %eax
f0102b08:	68 d1 02 00 00       	push   $0x2d1
f0102b0d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102b13:	50                   	push   %eax
f0102b14:	e8 09 d6 ff ff       	call   f0100122 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b19:	8d 83 5c ca fe ff    	lea    -0x135a4(%ebx),%eax
f0102b1f:	50                   	push   %eax
f0102b20:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102b26:	50                   	push   %eax
f0102b27:	68 d2 02 00 00       	push   $0x2d2
f0102b2c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102b32:	50                   	push   %eax
f0102b33:	e8 ea d5 ff ff       	call   f0100122 <_panic>
		switch (i) {
f0102b38:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b3e:	75 25                	jne    f0102b65 <mem_init+0x16d4>
			assert(pgdir[i] & PTE_P);
f0102b40:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102b44:	74 4c                	je     f0102b92 <mem_init+0x1701>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b46:	83 c7 01             	add    $0x1,%edi
f0102b49:	81 ff ff 03 00 00    	cmp    $0x3ff,%edi
f0102b4f:	0f 87 a7 00 00 00    	ja     f0102bfc <mem_init+0x176b>
		switch (i) {
f0102b55:	81 ff bd 03 00 00    	cmp    $0x3bd,%edi
f0102b5b:	77 db                	ja     f0102b38 <mem_init+0x16a7>
f0102b5d:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
f0102b63:	77 db                	ja     f0102b40 <mem_init+0x16af>
			if (i >= PDX(KERNBASE)) {
f0102b65:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b6b:	77 44                	ja     f0102bb1 <mem_init+0x1720>
				assert(pgdir[i] == 0);
f0102b6d:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102b71:	74 d3                	je     f0102b46 <mem_init+0x16b5>
f0102b73:	8d 83 95 ce fe ff    	lea    -0x1316b(%ebx),%eax
f0102b79:	50                   	push   %eax
f0102b7a:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102b80:	50                   	push   %eax
f0102b81:	68 e1 02 00 00       	push   $0x2e1
f0102b86:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102b8c:	50                   	push   %eax
f0102b8d:	e8 90 d5 ff ff       	call   f0100122 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b92:	8d 83 73 ce fe ff    	lea    -0x1318d(%ebx),%eax
f0102b98:	50                   	push   %eax
f0102b99:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102b9f:	50                   	push   %eax
f0102ba0:	68 da 02 00 00       	push   $0x2da
f0102ba5:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102bab:	50                   	push   %eax
f0102bac:	e8 71 d5 ff ff       	call   f0100122 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bb1:	8b 14 b8             	mov    (%eax,%edi,4),%edx
f0102bb4:	f6 c2 01             	test   $0x1,%dl
f0102bb7:	74 24                	je     f0102bdd <mem_init+0x174c>
				assert(pgdir[i] & PTE_W);
f0102bb9:	f6 c2 02             	test   $0x2,%dl
f0102bbc:	75 88                	jne    f0102b46 <mem_init+0x16b5>
f0102bbe:	8d 83 84 ce fe ff    	lea    -0x1317c(%ebx),%eax
f0102bc4:	50                   	push   %eax
f0102bc5:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102bcb:	50                   	push   %eax
f0102bcc:	68 df 02 00 00       	push   $0x2df
f0102bd1:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102bd7:	50                   	push   %eax
f0102bd8:	e8 45 d5 ff ff       	call   f0100122 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bdd:	8d 83 73 ce fe ff    	lea    -0x1318d(%ebx),%eax
f0102be3:	50                   	push   %eax
f0102be4:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102bea:	50                   	push   %eax
f0102beb:	68 de 02 00 00       	push   $0x2de
f0102bf0:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102bf6:	50                   	push   %eax
f0102bf7:	e8 26 d5 ff ff       	call   f0100122 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bfc:	83 ec 0c             	sub    $0xc,%esp
f0102bff:	8d 83 8c ca fe ff    	lea    -0x13574(%ebx),%eax
f0102c05:	50                   	push   %eax
f0102c06:	e8 c7 04 00 00       	call   f01030d2 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c0b:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102c11:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102c13:	83 c4 10             	add    $0x10,%esp
f0102c16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c1b:	0f 86 30 02 00 00    	jbe    f0102e51 <mem_init+0x19c0>
	return (physaddr_t)kva - KERNBASE;
f0102c21:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c26:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102c29:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c2e:	e8 b0 df ff ff       	call   f0100be3 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c33:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c36:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c39:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c3e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c41:	83 ec 0c             	sub    $0xc,%esp
f0102c44:	6a 00                	push   $0x0
f0102c46:	e8 ff e3 ff ff       	call   f010104a <page_alloc>
f0102c4b:	89 c7                	mov    %eax,%edi
f0102c4d:	83 c4 10             	add    $0x10,%esp
f0102c50:	85 c0                	test   %eax,%eax
f0102c52:	0f 84 12 02 00 00    	je     f0102e6a <mem_init+0x19d9>
	assert((pp1 = page_alloc(0)));
f0102c58:	83 ec 0c             	sub    $0xc,%esp
f0102c5b:	6a 00                	push   $0x0
f0102c5d:	e8 e8 e3 ff ff       	call   f010104a <page_alloc>
f0102c62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c65:	83 c4 10             	add    $0x10,%esp
f0102c68:	85 c0                	test   %eax,%eax
f0102c6a:	0f 84 19 02 00 00    	je     f0102e89 <mem_init+0x19f8>
	assert((pp2 = page_alloc(0)));
f0102c70:	83 ec 0c             	sub    $0xc,%esp
f0102c73:	6a 00                	push   $0x0
f0102c75:	e8 d0 e3 ff ff       	call   f010104a <page_alloc>
f0102c7a:	89 c6                	mov    %eax,%esi
f0102c7c:	83 c4 10             	add    $0x10,%esp
f0102c7f:	85 c0                	test   %eax,%eax
f0102c81:	0f 84 21 02 00 00    	je     f0102ea8 <mem_init+0x1a17>
	page_free(pp0);
f0102c87:	83 ec 0c             	sub    $0xc,%esp
f0102c8a:	57                   	push   %edi
f0102c8b:	e8 5d e4 ff ff       	call   f01010ed <page_free>
	return (pp - pages) << PGSHIFT;
f0102c90:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102c96:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c99:	2b 08                	sub    (%eax),%ecx
f0102c9b:	89 c8                	mov    %ecx,%eax
f0102c9d:	c1 f8 03             	sar    $0x3,%eax
f0102ca0:	89 c2                	mov    %eax,%edx
f0102ca2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ca5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102caa:	83 c4 10             	add    $0x10,%esp
f0102cad:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0102cb3:	3b 01                	cmp    (%ecx),%eax
f0102cb5:	0f 83 0c 02 00 00    	jae    f0102ec7 <mem_init+0x1a36>
	memset(page2kva(pp1), 1, PGSIZE);
f0102cbb:	83 ec 04             	sub    $0x4,%esp
f0102cbe:	68 00 10 00 00       	push   $0x1000
f0102cc3:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102cc5:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102ccb:	52                   	push   %edx
f0102ccc:	e8 66 10 00 00       	call   f0103d37 <memset>
	return (pp - pages) << PGSHIFT;
f0102cd1:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102cd7:	89 f1                	mov    %esi,%ecx
f0102cd9:	2b 08                	sub    (%eax),%ecx
f0102cdb:	89 c8                	mov    %ecx,%eax
f0102cdd:	c1 f8 03             	sar    $0x3,%eax
f0102ce0:	89 c2                	mov    %eax,%edx
f0102ce2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ce5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cea:	83 c4 10             	add    $0x10,%esp
f0102ced:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0102cf3:	3b 01                	cmp    (%ecx),%eax
f0102cf5:	0f 83 e2 01 00 00    	jae    f0102edd <mem_init+0x1a4c>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cfb:	83 ec 04             	sub    $0x4,%esp
f0102cfe:	68 00 10 00 00       	push   $0x1000
f0102d03:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d05:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d0b:	52                   	push   %edx
f0102d0c:	e8 26 10 00 00       	call   f0103d37 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d11:	6a 02                	push   $0x2
f0102d13:	68 00 10 00 00       	push   $0x1000
f0102d18:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102d1b:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102d21:	ff 30                	pushl  (%eax)
f0102d23:	e8 eb e6 ff ff       	call   f0101413 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d28:	83 c4 20             	add    $0x20,%esp
f0102d2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d2e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102d33:	0f 85 ba 01 00 00    	jne    f0102ef3 <mem_init+0x1a62>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d39:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d40:	01 01 01 
f0102d43:	0f 85 c9 01 00 00    	jne    f0102f12 <mem_init+0x1a81>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d49:	6a 02                	push   $0x2
f0102d4b:	68 00 10 00 00       	push   $0x1000
f0102d50:	56                   	push   %esi
f0102d51:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102d57:	ff 30                	pushl  (%eax)
f0102d59:	e8 b5 e6 ff ff       	call   f0101413 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d5e:	83 c4 10             	add    $0x10,%esp
f0102d61:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d68:	02 02 02 
f0102d6b:	0f 85 c0 01 00 00    	jne    f0102f31 <mem_init+0x1aa0>
	assert(pp2->pp_ref == 1);
f0102d71:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d76:	0f 85 d4 01 00 00    	jne    f0102f50 <mem_init+0x1abf>
	assert(pp1->pp_ref == 0);
f0102d7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d7f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d84:	0f 85 e5 01 00 00    	jne    f0102f6f <mem_init+0x1ade>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d8a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d91:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d94:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102d9a:	89 f1                	mov    %esi,%ecx
f0102d9c:	2b 08                	sub    (%eax),%ecx
f0102d9e:	89 c8                	mov    %ecx,%eax
f0102da0:	c1 f8 03             	sar    $0x3,%eax
f0102da3:	89 c2                	mov    %eax,%edx
f0102da5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102da8:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102dad:	c7 c1 a8 a6 11 f0    	mov    $0xf011a6a8,%ecx
f0102db3:	3b 01                	cmp    (%ecx),%eax
f0102db5:	0f 83 d3 01 00 00    	jae    f0102f8e <mem_init+0x1afd>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102dbb:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102dc2:	03 03 03 
f0102dc5:	0f 85 d9 01 00 00    	jne    f0102fa4 <mem_init+0x1b13>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102dcb:	83 ec 08             	sub    $0x8,%esp
f0102dce:	68 00 10 00 00       	push   $0x1000
f0102dd3:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102dd9:	ff 30                	pushl  (%eax)
f0102ddb:	e8 ed e5 ff ff       	call   f01013cd <page_remove>
	assert(pp2->pp_ref == 0);
f0102de0:	83 c4 10             	add    $0x10,%esp
f0102de3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102de8:	0f 85 d5 01 00 00    	jne    f0102fc3 <mem_init+0x1b32>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dee:	c7 c0 ac a6 11 f0    	mov    $0xf011a6ac,%eax
f0102df4:	8b 08                	mov    (%eax),%ecx
f0102df6:	8b 11                	mov    (%ecx),%edx
f0102df8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102dfe:	c7 c0 b0 a6 11 f0    	mov    $0xf011a6b0,%eax
f0102e04:	89 fe                	mov    %edi,%esi
f0102e06:	2b 30                	sub    (%eax),%esi
f0102e08:	89 f0                	mov    %esi,%eax
f0102e0a:	c1 f8 03             	sar    $0x3,%eax
f0102e0d:	c1 e0 0c             	shl    $0xc,%eax
f0102e10:	39 c2                	cmp    %eax,%edx
f0102e12:	0f 85 ca 01 00 00    	jne    f0102fe2 <mem_init+0x1b51>
	kern_pgdir[0] = 0;
f0102e18:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e1e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e23:	0f 85 d8 01 00 00    	jne    f0103001 <mem_init+0x1b70>
	pp0->pp_ref = 0;
f0102e29:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// free the pages we took
	page_free(pp0);
f0102e2f:	83 ec 0c             	sub    $0xc,%esp
f0102e32:	57                   	push   %edi
f0102e33:	e8 b5 e2 ff ff       	call   f01010ed <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e38:	8d 83 20 cb fe ff    	lea    -0x134e0(%ebx),%eax
f0102e3e:	89 04 24             	mov    %eax,(%esp)
f0102e41:	e8 8c 02 00 00       	call   f01030d2 <cprintf>
}
f0102e46:	83 c4 10             	add    $0x10,%esp
f0102e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e4c:	5b                   	pop    %ebx
f0102e4d:	5e                   	pop    %esi
f0102e4e:	5f                   	pop    %edi
f0102e4f:	5d                   	pop    %ebp
f0102e50:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e51:	50                   	push   %eax
f0102e52:	8d 83 bc c4 fe ff    	lea    -0x13b44(%ebx),%eax
f0102e58:	50                   	push   %eax
f0102e59:	68 de 00 00 00       	push   $0xde
f0102e5e:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102e64:	50                   	push   %eax
f0102e65:	e8 b8 d2 ff ff       	call   f0100122 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e6a:	8d 83 91 cc fe ff    	lea    -0x1336f(%ebx),%eax
f0102e70:	50                   	push   %eax
f0102e71:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	68 a1 03 00 00       	push   $0x3a1
f0102e7d:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102e83:	50                   	push   %eax
f0102e84:	e8 99 d2 ff ff       	call   f0100122 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e89:	8d 83 a7 cc fe ff    	lea    -0x13359(%ebx),%eax
f0102e8f:	50                   	push   %eax
f0102e90:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102e96:	50                   	push   %eax
f0102e97:	68 a2 03 00 00       	push   $0x3a2
f0102e9c:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102ea2:	50                   	push   %eax
f0102ea3:	e8 7a d2 ff ff       	call   f0100122 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ea8:	8d 83 bd cc fe ff    	lea    -0x13343(%ebx),%eax
f0102eae:	50                   	push   %eax
f0102eaf:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102eb5:	50                   	push   %eax
f0102eb6:	68 a3 03 00 00       	push   $0x3a3
f0102ebb:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102ec1:	50                   	push   %eax
f0102ec2:	e8 5b d2 ff ff       	call   f0100122 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ec7:	52                   	push   %edx
f0102ec8:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0102ece:	50                   	push   %eax
f0102ecf:	6a 52                	push   $0x52
f0102ed1:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0102ed7:	50                   	push   %eax
f0102ed8:	e8 45 d2 ff ff       	call   f0100122 <_panic>
f0102edd:	52                   	push   %edx
f0102ede:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0102ee4:	50                   	push   %eax
f0102ee5:	6a 52                	push   $0x52
f0102ee7:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0102eed:	50                   	push   %eax
f0102eee:	e8 2f d2 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 1);
f0102ef3:	8d 83 8e cd fe ff    	lea    -0x13272(%ebx),%eax
f0102ef9:	50                   	push   %eax
f0102efa:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	68 a8 03 00 00       	push   $0x3a8
f0102f06:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102f0c:	50                   	push   %eax
f0102f0d:	e8 10 d2 ff ff       	call   f0100122 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f12:	8d 83 ac ca fe ff    	lea    -0x13554(%ebx),%eax
f0102f18:	50                   	push   %eax
f0102f19:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102f1f:	50                   	push   %eax
f0102f20:	68 a9 03 00 00       	push   $0x3a9
f0102f25:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102f2b:	50                   	push   %eax
f0102f2c:	e8 f1 d1 ff ff       	call   f0100122 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f31:	8d 83 d0 ca fe ff    	lea    -0x13530(%ebx),%eax
f0102f37:	50                   	push   %eax
f0102f38:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102f3e:	50                   	push   %eax
f0102f3f:	68 ab 03 00 00       	push   $0x3ab
f0102f44:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102f4a:	50                   	push   %eax
f0102f4b:	e8 d2 d1 ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 1);
f0102f50:	8d 83 b0 cd fe ff    	lea    -0x13250(%ebx),%eax
f0102f56:	50                   	push   %eax
f0102f57:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102f5d:	50                   	push   %eax
f0102f5e:	68 ac 03 00 00       	push   $0x3ac
f0102f63:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102f69:	50                   	push   %eax
f0102f6a:	e8 b3 d1 ff ff       	call   f0100122 <_panic>
	assert(pp1->pp_ref == 0);
f0102f6f:	8d 83 1a ce fe ff    	lea    -0x131e6(%ebx),%eax
f0102f75:	50                   	push   %eax
f0102f76:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102f7c:	50                   	push   %eax
f0102f7d:	68 ad 03 00 00       	push   $0x3ad
f0102f82:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102f88:	50                   	push   %eax
f0102f89:	e8 94 d1 ff ff       	call   f0100122 <_panic>
f0102f8e:	52                   	push   %edx
f0102f8f:	8d 83 b0 c3 fe ff    	lea    -0x13c50(%ebx),%eax
f0102f95:	50                   	push   %eax
f0102f96:	6a 52                	push   $0x52
f0102f98:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0102f9e:	50                   	push   %eax
f0102f9f:	e8 7e d1 ff ff       	call   f0100122 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102fa4:	8d 83 f4 ca fe ff    	lea    -0x1350c(%ebx),%eax
f0102faa:	50                   	push   %eax
f0102fab:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102fb1:	50                   	push   %eax
f0102fb2:	68 af 03 00 00       	push   $0x3af
f0102fb7:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102fbd:	50                   	push   %eax
f0102fbe:	e8 5f d1 ff ff       	call   f0100122 <_panic>
	assert(pp2->pp_ref == 0);
f0102fc3:	8d 83 e8 cd fe ff    	lea    -0x13218(%ebx),%eax
f0102fc9:	50                   	push   %eax
f0102fca:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102fd0:	50                   	push   %eax
f0102fd1:	68 b1 03 00 00       	push   $0x3b1
f0102fd6:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102fdc:	50                   	push   %eax
f0102fdd:	e8 40 d1 ff ff       	call   f0100122 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fe2:	8d 83 38 c6 fe ff    	lea    -0x139c8(%ebx),%eax
f0102fe8:	50                   	push   %eax
f0102fe9:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f0102fef:	50                   	push   %eax
f0102ff0:	68 b4 03 00 00       	push   $0x3b4
f0102ff5:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f0102ffb:	50                   	push   %eax
f0102ffc:	e8 21 d1 ff ff       	call   f0100122 <_panic>
	assert(pp0->pp_ref == 1);
f0103001:	8d 83 9f cd fe ff    	lea    -0x13261(%ebx),%eax
f0103007:	50                   	push   %eax
f0103008:	8d 83 6f cb fe ff    	lea    -0x13491(%ebx),%eax
f010300e:	50                   	push   %eax
f010300f:	68 b6 03 00 00       	push   $0x3b6
f0103014:	8d 83 49 cb fe ff    	lea    -0x134b7(%ebx),%eax
f010301a:	50                   	push   %eax
f010301b:	e8 02 d1 ff ff       	call   f0100122 <_panic>

f0103020 <tlb_invalidate>:
{
f0103020:	f3 0f 1e fb          	endbr32 
f0103024:	55                   	push   %ebp
f0103025:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0103027:	8b 45 0c             	mov    0xc(%ebp),%eax
f010302a:	0f 01 38             	invlpg (%eax)
}
f010302d:	5d                   	pop    %ebp
f010302e:	c3                   	ret    

f010302f <__x86.get_pc_thunk.dx>:
f010302f:	8b 14 24             	mov    (%esp),%edx
f0103032:	c3                   	ret    

f0103033 <__x86.get_pc_thunk.cx>:
f0103033:	8b 0c 24             	mov    (%esp),%ecx
f0103036:	c3                   	ret    

f0103037 <__x86.get_pc_thunk.di>:
f0103037:	8b 3c 24             	mov    (%esp),%edi
f010303a:	c3                   	ret    

f010303b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010303b:	f3 0f 1e fb          	endbr32 
f010303f:	55                   	push   %ebp
f0103040:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103042:	8b 45 08             	mov    0x8(%ebp),%eax
f0103045:	ba 70 00 00 00       	mov    $0x70,%edx
f010304a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010304b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103050:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103051:	0f b6 c0             	movzbl %al,%eax
}
f0103054:	5d                   	pop    %ebp
f0103055:	c3                   	ret    

f0103056 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103056:	f3 0f 1e fb          	endbr32 
f010305a:	55                   	push   %ebp
f010305b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010305d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103060:	ba 70 00 00 00       	mov    $0x70,%edx
f0103065:	ee                   	out    %al,(%dx)
f0103066:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103069:	ba 71 00 00 00       	mov    $0x71,%edx
f010306e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010306f:	5d                   	pop    %ebp
f0103070:	c3                   	ret    

f0103071 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103071:	f3 0f 1e fb          	endbr32 
f0103075:	55                   	push   %ebp
f0103076:	89 e5                	mov    %esp,%ebp
f0103078:	53                   	push   %ebx
f0103079:	83 ec 10             	sub    $0x10,%esp
f010307c:	e8 5f d1 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0103081:	81 c3 87 52 01 00    	add    $0x15287,%ebx
	cputchar(ch);
f0103087:	ff 75 08             	pushl  0x8(%ebp)
f010308a:	e8 d2 d6 ff ff       	call   f0100761 <cputchar>
	*cnt++;
}
f010308f:	83 c4 10             	add    $0x10,%esp
f0103092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103095:	c9                   	leave  
f0103096:	c3                   	ret    

f0103097 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103097:	f3 0f 1e fb          	endbr32 
f010309b:	55                   	push   %ebp
f010309c:	89 e5                	mov    %esp,%ebp
f010309e:	53                   	push   %ebx
f010309f:	83 ec 14             	sub    $0x14,%esp
f01030a2:	e8 39 d1 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01030a7:	81 c3 61 52 01 00    	add    $0x15261,%ebx
	int cnt = 0;
f01030ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030b4:	ff 75 0c             	pushl  0xc(%ebp)
f01030b7:	ff 75 08             	pushl  0x8(%ebp)
f01030ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030bd:	50                   	push   %eax
f01030be:	8d 83 69 ad fe ff    	lea    -0x15297(%ebx),%eax
f01030c4:	50                   	push   %eax
f01030c5:	e8 81 04 00 00       	call   f010354b <vprintfmt>
	return cnt;
}
f01030ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030d0:	c9                   	leave  
f01030d1:	c3                   	ret    

f01030d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030d2:	f3 0f 1e fb          	endbr32 
f01030d6:	55                   	push   %ebp
f01030d7:	89 e5                	mov    %esp,%ebp
f01030d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01030dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01030df:	50                   	push   %eax
f01030e0:	ff 75 08             	pushl  0x8(%ebp)
f01030e3:	e8 af ff ff ff       	call   f0103097 <vcprintf>
	va_end(ap);

	return cnt;
}
f01030e8:	c9                   	leave  
f01030e9:	c3                   	ret    

f01030ea <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01030ea:	55                   	push   %ebp
f01030eb:	89 e5                	mov    %esp,%ebp
f01030ed:	57                   	push   %edi
f01030ee:	56                   	push   %esi
f01030ef:	53                   	push   %ebx
f01030f0:	83 ec 14             	sub    $0x14,%esp
f01030f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01030f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01030f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01030fc:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01030ff:	8b 1a                	mov    (%edx),%ebx
f0103101:	8b 01                	mov    (%ecx),%eax
f0103103:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103106:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010310d:	eb 23                	jmp    f0103132 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010310f:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103112:	eb 1e                	jmp    f0103132 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103114:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103117:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010311a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010311e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103121:	73 46                	jae    f0103169 <stab_binsearch+0x7f>
			*region_left = m;
f0103123:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103126:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103128:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010312b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103132:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103135:	7f 5f                	jg     f0103196 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103137:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010313a:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010313d:	89 d0                	mov    %edx,%eax
f010313f:	c1 e8 1f             	shr    $0x1f,%eax
f0103142:	01 d0                	add    %edx,%eax
f0103144:	89 c7                	mov    %eax,%edi
f0103146:	d1 ff                	sar    %edi
f0103148:	83 e0 fe             	and    $0xfffffffe,%eax
f010314b:	01 f8                	add    %edi,%eax
f010314d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103150:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103154:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103156:	39 c3                	cmp    %eax,%ebx
f0103158:	7f b5                	jg     f010310f <stab_binsearch+0x25>
f010315a:	0f b6 0a             	movzbl (%edx),%ecx
f010315d:	83 ea 0c             	sub    $0xc,%edx
f0103160:	39 f1                	cmp    %esi,%ecx
f0103162:	74 b0                	je     f0103114 <stab_binsearch+0x2a>
			m--;
f0103164:	83 e8 01             	sub    $0x1,%eax
f0103167:	eb ed                	jmp    f0103156 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0103169:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010316c:	76 14                	jbe    f0103182 <stab_binsearch+0x98>
			*region_right = m - 1;
f010316e:	83 e8 01             	sub    $0x1,%eax
f0103171:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103174:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103177:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103179:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103180:	eb b0                	jmp    f0103132 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103182:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103185:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103187:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010318b:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010318d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103194:	eb 9c                	jmp    f0103132 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0103196:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010319a:	75 15                	jne    f01031b1 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010319c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010319f:	8b 00                	mov    (%eax),%eax
f01031a1:	83 e8 01             	sub    $0x1,%eax
f01031a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01031a7:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01031a9:	83 c4 14             	add    $0x14,%esp
f01031ac:	5b                   	pop    %ebx
f01031ad:	5e                   	pop    %esi
f01031ae:	5f                   	pop    %edi
f01031af:	5d                   	pop    %ebp
f01031b0:	c3                   	ret    
		for (l = *region_right;
f01031b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031b4:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01031b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031b9:	8b 0f                	mov    (%edi),%ecx
f01031bb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01031be:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01031c1:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01031c5:	eb 03                	jmp    f01031ca <stab_binsearch+0xe0>
		     l--)
f01031c7:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01031ca:	39 c1                	cmp    %eax,%ecx
f01031cc:	7d 0a                	jge    f01031d8 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01031ce:	0f b6 1a             	movzbl (%edx),%ebx
f01031d1:	83 ea 0c             	sub    $0xc,%edx
f01031d4:	39 f3                	cmp    %esi,%ebx
f01031d6:	75 ef                	jne    f01031c7 <stab_binsearch+0xdd>
		*region_left = l;
f01031d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031db:	89 07                	mov    %eax,(%edi)
}
f01031dd:	eb ca                	jmp    f01031a9 <stab_binsearch+0xbf>

f01031df <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01031df:	f3 0f 1e fb          	endbr32 
f01031e3:	55                   	push   %ebp
f01031e4:	89 e5                	mov    %esp,%ebp
f01031e6:	57                   	push   %edi
f01031e7:	56                   	push   %esi
f01031e8:	53                   	push   %ebx
f01031e9:	83 ec 3c             	sub    $0x3c,%esp
f01031ec:	e8 ef cf ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f01031f1:	81 c3 17 51 01 00    	add    $0x15117,%ebx
f01031f7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01031fd:	8d 83 a3 ce fe ff    	lea    -0x1315d(%ebx),%eax
f0103203:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103205:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010320c:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f010320f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103216:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103219:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103220:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103226:	0f 86 36 01 00 00    	jbe    f0103362 <debuginfo_eip+0x183>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010322c:	c7 c0 15 c8 10 f0    	mov    $0xf010c815,%eax
f0103232:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0103238:	0f 86 eb 01 00 00    	jbe    f0103429 <debuginfo_eip+0x24a>
f010323e:	c7 c0 ae e6 10 f0    	mov    $0xf010e6ae,%eax
f0103244:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103248:	0f 85 e2 01 00 00    	jne    f0103430 <debuginfo_eip+0x251>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010324e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103255:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f010325b:	c7 c2 14 c8 10 f0    	mov    $0xf010c814,%edx
f0103261:	29 c2                	sub    %eax,%edx
f0103263:	c1 fa 02             	sar    $0x2,%edx
f0103266:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010326c:	83 ea 01             	sub    $0x1,%edx
f010326f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103272:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103275:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103278:	83 ec 08             	sub    $0x8,%esp
f010327b:	57                   	push   %edi
f010327c:	6a 64                	push   $0x64
f010327e:	e8 67 fe ff ff       	call   f01030ea <stab_binsearch>
	if (lfile == 0)
f0103283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103286:	83 c4 10             	add    $0x10,%esp
f0103289:	85 c0                	test   %eax,%eax
f010328b:	0f 84 a6 01 00 00    	je     f0103437 <debuginfo_eip+0x258>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103291:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103294:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103297:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010329a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010329d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01032a0:	83 ec 08             	sub    $0x8,%esp
f01032a3:	57                   	push   %edi
f01032a4:	6a 24                	push   $0x24
f01032a6:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f01032ac:	e8 39 fe ff ff       	call   f01030ea <stab_binsearch>

	if (lfun <= rfun) {
f01032b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01032b4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01032b7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01032ba:	83 c4 10             	add    $0x10,%esp
f01032bd:	39 c8                	cmp    %ecx,%eax
f01032bf:	0f 8f b5 00 00 00    	jg     f010337a <debuginfo_eip+0x19b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01032c5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032c8:	c7 c1 d4 53 10 f0    	mov    $0xf01053d4,%ecx
f01032ce:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f01032d1:	8b 11                	mov    (%ecx),%edx
f01032d3:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01032d6:	c7 c2 ae e6 10 f0    	mov    $0xf010e6ae,%edx
f01032dc:	81 ea 15 c8 10 f0    	sub    $0xf010c815,%edx
f01032e2:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f01032e5:	73 0c                	jae    f01032f3 <debuginfo_eip+0x114>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01032e7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01032ea:	81 c2 15 c8 10 f0    	add    $0xf010c815,%edx
f01032f0:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01032f3:	8b 51 08             	mov    0x8(%ecx),%edx
f01032f6:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f01032f9:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01032fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01032fe:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103301:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103304:	83 ec 08             	sub    $0x8,%esp
f0103307:	6a 3a                	push   $0x3a
f0103309:	ff 76 08             	pushl  0x8(%esi)
f010330c:	e8 06 0a 00 00       	call   f0103d17 <strfind>
f0103311:	2b 46 08             	sub    0x8(%esi),%eax
f0103314:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103317:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010331a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010331d:	83 c4 08             	add    $0x8,%esp
f0103320:	57                   	push   %edi
f0103321:	6a 44                	push   $0x44
f0103323:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f0103329:	e8 bc fd ff ff       	call   f01030ea <stab_binsearch>
	if (lline <= rline){
f010332e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103331:	83 c4 10             	add    $0x10,%esp
f0103334:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103337:	7f 55                	jg     f010338e <debuginfo_eip+0x1af>
		info->eip_line = stabs[lline].n_desc;
f0103339:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010333c:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f0103342:	0f b7 44 90 06       	movzwl 0x6(%eax,%edx,4),%eax
f0103347:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010334a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010334d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103350:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0103353:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f0103359:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f010335d:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103360:	eb 46                	jmp    f01033a8 <debuginfo_eip+0x1c9>
  	        panic("User address");
f0103362:	83 ec 04             	sub    $0x4,%esp
f0103365:	8d 83 ad ce fe ff    	lea    -0x13153(%ebx),%eax
f010336b:	50                   	push   %eax
f010336c:	6a 7f                	push   $0x7f
f010336e:	8d 83 ba ce fe ff    	lea    -0x13146(%ebx),%eax
f0103374:	50                   	push   %eax
f0103375:	e8 a8 cd ff ff       	call   f0100122 <_panic>
		info->eip_fn_addr = addr;
f010337a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010337d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103380:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103383:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103386:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103389:	e9 76 ff ff ff       	jmp    f0103304 <debuginfo_eip+0x125>
		cprintf("line not found\n");
f010338e:	83 ec 0c             	sub    $0xc,%esp
f0103391:	8d 83 c8 ce fe ff    	lea    -0x13138(%ebx),%eax
f0103397:	50                   	push   %eax
f0103398:	e8 35 fd ff ff       	call   f01030d2 <cprintf>
f010339d:	83 c4 10             	add    $0x10,%esp
f01033a0:	eb a8                	jmp    f010334a <debuginfo_eip+0x16b>
f01033a2:	83 ea 01             	sub    $0x1,%edx
f01033a5:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f01033a8:	39 d7                	cmp    %edx,%edi
f01033aa:	7f 3c                	jg     f01033e8 <debuginfo_eip+0x209>
	       && stabs[lline].n_type != N_SOL
f01033ac:	0f b6 08             	movzbl (%eax),%ecx
f01033af:	80 f9 84             	cmp    $0x84,%cl
f01033b2:	74 0b                	je     f01033bf <debuginfo_eip+0x1e0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01033b4:	80 f9 64             	cmp    $0x64,%cl
f01033b7:	75 e9                	jne    f01033a2 <debuginfo_eip+0x1c3>
f01033b9:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f01033bd:	74 e3                	je     f01033a2 <debuginfo_eip+0x1c3>
f01033bf:	8b 75 0c             	mov    0xc(%ebp),%esi
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01033c2:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01033c5:	c7 c0 d4 53 10 f0    	mov    $0xf01053d4,%eax
f01033cb:	8b 14 90             	mov    (%eax,%edx,4),%edx
f01033ce:	c7 c0 ae e6 10 f0    	mov    $0xf010e6ae,%eax
f01033d4:	81 e8 15 c8 10 f0    	sub    $0xf010c815,%eax
f01033da:	39 c2                	cmp    %eax,%edx
f01033dc:	73 0d                	jae    f01033eb <debuginfo_eip+0x20c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01033de:	81 c2 15 c8 10 f0    	add    $0xf010c815,%edx
f01033e4:	89 16                	mov    %edx,(%esi)
f01033e6:	eb 03                	jmp    f01033eb <debuginfo_eip+0x20c>
f01033e8:	8b 75 0c             	mov    0xc(%ebp),%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01033eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01033f1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01033f6:	39 fa                	cmp    %edi,%edx
f01033f8:	7d 49                	jge    f0103443 <debuginfo_eip+0x264>
		for (lline = lfun + 1;
f01033fa:	8d 42 01             	lea    0x1(%edx),%eax
f01033fd:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103400:	c7 c2 d4 53 10 f0    	mov    $0xf01053d4,%edx
f0103406:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f010340a:	eb 04                	jmp    f0103410 <debuginfo_eip+0x231>
			info->eip_fn_narg++;
f010340c:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103410:	39 c7                	cmp    %eax,%edi
f0103412:	7e 2a                	jle    f010343e <debuginfo_eip+0x25f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103414:	0f b6 0a             	movzbl (%edx),%ecx
f0103417:	83 c0 01             	add    $0x1,%eax
f010341a:	83 c2 0c             	add    $0xc,%edx
f010341d:	80 f9 a0             	cmp    $0xa0,%cl
f0103420:	74 ea                	je     f010340c <debuginfo_eip+0x22d>
	return 0;
f0103422:	b8 00 00 00 00       	mov    $0x0,%eax
f0103427:	eb 1a                	jmp    f0103443 <debuginfo_eip+0x264>
		return -1;
f0103429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010342e:	eb 13                	jmp    f0103443 <debuginfo_eip+0x264>
f0103430:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103435:	eb 0c                	jmp    f0103443 <debuginfo_eip+0x264>
		return -1;
f0103437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010343c:	eb 05                	jmp    f0103443 <debuginfo_eip+0x264>
	return 0;
f010343e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103443:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103446:	5b                   	pop    %ebx
f0103447:	5e                   	pop    %esi
f0103448:	5f                   	pop    %edi
f0103449:	5d                   	pop    %ebp
f010344a:	c3                   	ret    

f010344b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010344b:	55                   	push   %ebp
f010344c:	89 e5                	mov    %esp,%ebp
f010344e:	57                   	push   %edi
f010344f:	56                   	push   %esi
f0103450:	53                   	push   %ebx
f0103451:	83 ec 2c             	sub    $0x2c,%esp
f0103454:	e8 da fb ff ff       	call   f0103033 <__x86.get_pc_thunk.cx>
f0103459:	81 c1 af 4e 01 00    	add    $0x14eaf,%ecx
f010345f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103462:	89 c7                	mov    %eax,%edi
f0103464:	89 d6                	mov    %edx,%esi
f0103466:	8b 45 08             	mov    0x8(%ebp),%eax
f0103469:	8b 55 0c             	mov    0xc(%ebp),%edx
f010346c:	89 d1                	mov    %edx,%ecx
f010346e:	89 c2                	mov    %eax,%edx
f0103470:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103473:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103476:	8b 45 10             	mov    0x10(%ebp),%eax
f0103479:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010347c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010347f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103486:	39 c2                	cmp    %eax,%edx
f0103488:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010348b:	72 41                	jb     f01034ce <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010348d:	83 ec 0c             	sub    $0xc,%esp
f0103490:	ff 75 18             	pushl  0x18(%ebp)
f0103493:	83 eb 01             	sub    $0x1,%ebx
f0103496:	53                   	push   %ebx
f0103497:	50                   	push   %eax
f0103498:	83 ec 08             	sub    $0x8,%esp
f010349b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010349e:	ff 75 e0             	pushl  -0x20(%ebp)
f01034a1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01034a4:	ff 75 d0             	pushl  -0x30(%ebp)
f01034a7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01034aa:	e8 91 0a 00 00       	call   f0103f40 <__udivdi3>
f01034af:	83 c4 18             	add    $0x18,%esp
f01034b2:	52                   	push   %edx
f01034b3:	50                   	push   %eax
f01034b4:	89 f2                	mov    %esi,%edx
f01034b6:	89 f8                	mov    %edi,%eax
f01034b8:	e8 8e ff ff ff       	call   f010344b <printnum>
f01034bd:	83 c4 20             	add    $0x20,%esp
f01034c0:	eb 13                	jmp    f01034d5 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01034c2:	83 ec 08             	sub    $0x8,%esp
f01034c5:	56                   	push   %esi
f01034c6:	ff 75 18             	pushl  0x18(%ebp)
f01034c9:	ff d7                	call   *%edi
f01034cb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01034ce:	83 eb 01             	sub    $0x1,%ebx
f01034d1:	85 db                	test   %ebx,%ebx
f01034d3:	7f ed                	jg     f01034c2 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01034d5:	83 ec 08             	sub    $0x8,%esp
f01034d8:	56                   	push   %esi
f01034d9:	83 ec 04             	sub    $0x4,%esp
f01034dc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01034df:	ff 75 e0             	pushl  -0x20(%ebp)
f01034e2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01034e5:	ff 75 d0             	pushl  -0x30(%ebp)
f01034e8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01034eb:	e8 60 0b 00 00       	call   f0104050 <__umoddi3>
f01034f0:	83 c4 14             	add    $0x14,%esp
f01034f3:	0f be 84 03 d8 ce fe 	movsbl -0x13128(%ebx,%eax,1),%eax
f01034fa:	ff 
f01034fb:	50                   	push   %eax
f01034fc:	ff d7                	call   *%edi
}
f01034fe:	83 c4 10             	add    $0x10,%esp
f0103501:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103504:	5b                   	pop    %ebx
f0103505:	5e                   	pop    %esi
f0103506:	5f                   	pop    %edi
f0103507:	5d                   	pop    %ebp
f0103508:	c3                   	ret    

f0103509 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103509:	f3 0f 1e fb          	endbr32 
f010350d:	55                   	push   %ebp
f010350e:	89 e5                	mov    %esp,%ebp
f0103510:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103513:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103517:	8b 10                	mov    (%eax),%edx
f0103519:	3b 50 04             	cmp    0x4(%eax),%edx
f010351c:	73 0a                	jae    f0103528 <sprintputch+0x1f>
		*b->buf++ = ch;
f010351e:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103521:	89 08                	mov    %ecx,(%eax)
f0103523:	8b 45 08             	mov    0x8(%ebp),%eax
f0103526:	88 02                	mov    %al,(%edx)
}
f0103528:	5d                   	pop    %ebp
f0103529:	c3                   	ret    

f010352a <printfmt>:
{
f010352a:	f3 0f 1e fb          	endbr32 
f010352e:	55                   	push   %ebp
f010352f:	89 e5                	mov    %esp,%ebp
f0103531:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103534:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103537:	50                   	push   %eax
f0103538:	ff 75 10             	pushl  0x10(%ebp)
f010353b:	ff 75 0c             	pushl  0xc(%ebp)
f010353e:	ff 75 08             	pushl  0x8(%ebp)
f0103541:	e8 05 00 00 00       	call   f010354b <vprintfmt>
}
f0103546:	83 c4 10             	add    $0x10,%esp
f0103549:	c9                   	leave  
f010354a:	c3                   	ret    

f010354b <vprintfmt>:
{
f010354b:	f3 0f 1e fb          	endbr32 
f010354f:	55                   	push   %ebp
f0103550:	89 e5                	mov    %esp,%ebp
f0103552:	57                   	push   %edi
f0103553:	56                   	push   %esi
f0103554:	53                   	push   %ebx
f0103555:	83 ec 3c             	sub    $0x3c,%esp
f0103558:	e8 37 d2 ff ff       	call   f0100794 <__x86.get_pc_thunk.ax>
f010355d:	05 ab 4d 01 00       	add    $0x14dab,%eax
f0103562:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103565:	8b 75 08             	mov    0x8(%ebp),%esi
f0103568:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010356b:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010356e:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0103574:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103577:	e9 cd 03 00 00       	jmp    f0103949 <.L25+0x48>
		padc = ' ';
f010357c:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0103580:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0103587:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010358e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103595:	b9 00 00 00 00       	mov    $0x0,%ecx
f010359a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010359d:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035a0:	8d 43 01             	lea    0x1(%ebx),%eax
f01035a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01035a6:	0f b6 13             	movzbl (%ebx),%edx
f01035a9:	8d 42 dd             	lea    -0x23(%edx),%eax
f01035ac:	3c 55                	cmp    $0x55,%al
f01035ae:	0f 87 21 04 00 00    	ja     f01039d5 <.L20>
f01035b4:	0f b6 c0             	movzbl %al,%eax
f01035b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01035ba:	89 ce                	mov    %ecx,%esi
f01035bc:	03 b4 81 64 cf fe ff 	add    -0x1309c(%ecx,%eax,4),%esi
f01035c3:	3e ff e6             	notrack jmp *%esi

f01035c6 <.L68>:
f01035c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01035c9:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01035cd:	eb d1                	jmp    f01035a0 <vprintfmt+0x55>

f01035cf <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01035cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01035d2:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01035d6:	eb c8                	jmp    f01035a0 <vprintfmt+0x55>

f01035d8 <.L31>:
f01035d8:	0f b6 d2             	movzbl %dl,%edx
f01035db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01035de:	b8 00 00 00 00       	mov    $0x0,%eax
f01035e3:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01035e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01035e9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01035ed:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01035f0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01035f3:	83 f9 09             	cmp    $0x9,%ecx
f01035f6:	77 58                	ja     f0103650 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01035f8:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01035fb:	eb e9                	jmp    f01035e6 <.L31+0xe>

f01035fd <.L34>:
			precision = va_arg(ap, int);
f01035fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103600:	8b 00                	mov    (%eax),%eax
f0103602:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103605:	8b 45 14             	mov    0x14(%ebp),%eax
f0103608:	8d 40 04             	lea    0x4(%eax),%eax
f010360b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010360e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0103611:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103615:	79 89                	jns    f01035a0 <vprintfmt+0x55>
				width = precision, precision = -1;
f0103617:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010361a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010361d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103624:	e9 77 ff ff ff       	jmp    f01035a0 <vprintfmt+0x55>

f0103629 <.L33>:
f0103629:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010362c:	85 c0                	test   %eax,%eax
f010362e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103633:	0f 49 d0             	cmovns %eax,%edx
f0103636:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103639:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010363c:	e9 5f ff ff ff       	jmp    f01035a0 <vprintfmt+0x55>

f0103641 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0103641:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0103644:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f010364b:	e9 50 ff ff ff       	jmp    f01035a0 <vprintfmt+0x55>
f0103650:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103653:	89 75 08             	mov    %esi,0x8(%ebp)
f0103656:	eb b9                	jmp    f0103611 <.L34+0x14>

f0103658 <.L27>:
			lflag++;
f0103658:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010365c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010365f:	e9 3c ff ff ff       	jmp    f01035a0 <vprintfmt+0x55>

f0103664 <.L30>:
f0103664:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0103667:	8b 45 14             	mov    0x14(%ebp),%eax
f010366a:	8d 58 04             	lea    0x4(%eax),%ebx
f010366d:	83 ec 08             	sub    $0x8,%esp
f0103670:	57                   	push   %edi
f0103671:	ff 30                	pushl  (%eax)
f0103673:	ff d6                	call   *%esi
			break;
f0103675:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103678:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010367b:	e9 c6 02 00 00       	jmp    f0103946 <.L25+0x45>

f0103680 <.L28>:
f0103680:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0103683:	8b 45 14             	mov    0x14(%ebp),%eax
f0103686:	8d 58 04             	lea    0x4(%eax),%ebx
f0103689:	8b 00                	mov    (%eax),%eax
f010368b:	99                   	cltd   
f010368c:	31 d0                	xor    %edx,%eax
f010368e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103690:	83 f8 06             	cmp    $0x6,%eax
f0103693:	7f 27                	jg     f01036bc <.L28+0x3c>
f0103695:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103698:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010369b:	85 d2                	test   %edx,%edx
f010369d:	74 1d                	je     f01036bc <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010369f:	52                   	push   %edx
f01036a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036a3:	8d 80 81 cb fe ff    	lea    -0x1347f(%eax),%eax
f01036a9:	50                   	push   %eax
f01036aa:	57                   	push   %edi
f01036ab:	56                   	push   %esi
f01036ac:	e8 79 fe ff ff       	call   f010352a <printfmt>
f01036b1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01036b4:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01036b7:	e9 8a 02 00 00       	jmp    f0103946 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01036bc:	50                   	push   %eax
f01036bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036c0:	8d 80 f0 ce fe ff    	lea    -0x13110(%eax),%eax
f01036c6:	50                   	push   %eax
f01036c7:	57                   	push   %edi
f01036c8:	56                   	push   %esi
f01036c9:	e8 5c fe ff ff       	call   f010352a <printfmt>
f01036ce:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01036d1:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01036d4:	e9 6d 02 00 00       	jmp    f0103946 <.L25+0x45>

f01036d9 <.L24>:
f01036d9:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01036dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01036df:	83 c0 04             	add    $0x4,%eax
f01036e2:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01036e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01036e8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01036ea:	85 d2                	test   %edx,%edx
f01036ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036ef:	8d 80 e9 ce fe ff    	lea    -0x13117(%eax),%eax
f01036f5:	0f 45 c2             	cmovne %edx,%eax
f01036f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01036fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01036ff:	7e 06                	jle    f0103707 <.L24+0x2e>
f0103701:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0103705:	75 0d                	jne    f0103714 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103707:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010370a:	89 c3                	mov    %eax,%ebx
f010370c:	03 45 d4             	add    -0x2c(%ebp),%eax
f010370f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103712:	eb 58                	jmp    f010376c <.L24+0x93>
f0103714:	83 ec 08             	sub    $0x8,%esp
f0103717:	ff 75 d8             	pushl  -0x28(%ebp)
f010371a:	ff 75 c8             	pushl  -0x38(%ebp)
f010371d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103720:	e8 81 04 00 00       	call   f0103ba6 <strnlen>
f0103725:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103728:	29 c2                	sub    %eax,%edx
f010372a:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010372d:	83 c4 10             	add    $0x10,%esp
f0103730:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0103732:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0103736:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103739:	85 db                	test   %ebx,%ebx
f010373b:	7e 11                	jle    f010374e <.L24+0x75>
					putch(padc, putdat);
f010373d:	83 ec 08             	sub    $0x8,%esp
f0103740:	57                   	push   %edi
f0103741:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103744:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103746:	83 eb 01             	sub    $0x1,%ebx
f0103749:	83 c4 10             	add    $0x10,%esp
f010374c:	eb eb                	jmp    f0103739 <.L24+0x60>
f010374e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103751:	85 d2                	test   %edx,%edx
f0103753:	b8 00 00 00 00       	mov    $0x0,%eax
f0103758:	0f 49 c2             	cmovns %edx,%eax
f010375b:	29 c2                	sub    %eax,%edx
f010375d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103760:	eb a5                	jmp    f0103707 <.L24+0x2e>
					putch(ch, putdat);
f0103762:	83 ec 08             	sub    $0x8,%esp
f0103765:	57                   	push   %edi
f0103766:	52                   	push   %edx
f0103767:	ff d6                	call   *%esi
f0103769:	83 c4 10             	add    $0x10,%esp
f010376c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010376f:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103771:	83 c3 01             	add    $0x1,%ebx
f0103774:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103778:	0f be d0             	movsbl %al,%edx
f010377b:	85 d2                	test   %edx,%edx
f010377d:	74 4b                	je     f01037ca <.L24+0xf1>
f010377f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103783:	78 06                	js     f010378b <.L24+0xb2>
f0103785:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0103789:	78 1e                	js     f01037a9 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010378b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010378f:	74 d1                	je     f0103762 <.L24+0x89>
f0103791:	0f be c0             	movsbl %al,%eax
f0103794:	83 e8 20             	sub    $0x20,%eax
f0103797:	83 f8 5e             	cmp    $0x5e,%eax
f010379a:	76 c6                	jbe    f0103762 <.L24+0x89>
					putch('?', putdat);
f010379c:	83 ec 08             	sub    $0x8,%esp
f010379f:	57                   	push   %edi
f01037a0:	6a 3f                	push   $0x3f
f01037a2:	ff d6                	call   *%esi
f01037a4:	83 c4 10             	add    $0x10,%esp
f01037a7:	eb c3                	jmp    f010376c <.L24+0x93>
f01037a9:	89 cb                	mov    %ecx,%ebx
f01037ab:	eb 0e                	jmp    f01037bb <.L24+0xe2>
				putch(' ', putdat);
f01037ad:	83 ec 08             	sub    $0x8,%esp
f01037b0:	57                   	push   %edi
f01037b1:	6a 20                	push   $0x20
f01037b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01037b5:	83 eb 01             	sub    $0x1,%ebx
f01037b8:	83 c4 10             	add    $0x10,%esp
f01037bb:	85 db                	test   %ebx,%ebx
f01037bd:	7f ee                	jg     f01037ad <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01037bf:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01037c2:	89 45 14             	mov    %eax,0x14(%ebp)
f01037c5:	e9 7c 01 00 00       	jmp    f0103946 <.L25+0x45>
f01037ca:	89 cb                	mov    %ecx,%ebx
f01037cc:	eb ed                	jmp    f01037bb <.L24+0xe2>

f01037ce <.L29>:
f01037ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01037d1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01037d4:	83 f9 01             	cmp    $0x1,%ecx
f01037d7:	7f 1b                	jg     f01037f4 <.L29+0x26>
	else if (lflag)
f01037d9:	85 c9                	test   %ecx,%ecx
f01037db:	74 63                	je     f0103840 <.L29+0x72>
		return va_arg(*ap, long);
f01037dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01037e0:	8b 00                	mov    (%eax),%eax
f01037e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037e5:	99                   	cltd   
f01037e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01037ec:	8d 40 04             	lea    0x4(%eax),%eax
f01037ef:	89 45 14             	mov    %eax,0x14(%ebp)
f01037f2:	eb 17                	jmp    f010380b <.L29+0x3d>
		return va_arg(*ap, long long);
f01037f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f7:	8b 50 04             	mov    0x4(%eax),%edx
f01037fa:	8b 00                	mov    (%eax),%eax
f01037fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103802:	8b 45 14             	mov    0x14(%ebp),%eax
f0103805:	8d 40 08             	lea    0x8(%eax),%eax
f0103808:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010380b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010380e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103811:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0103816:	85 c9                	test   %ecx,%ecx
f0103818:	0f 89 0e 01 00 00    	jns    f010392c <.L25+0x2b>
				putch('-', putdat);
f010381e:	83 ec 08             	sub    $0x8,%esp
f0103821:	57                   	push   %edi
f0103822:	6a 2d                	push   $0x2d
f0103824:	ff d6                	call   *%esi
				num = -(long long) num;
f0103826:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103829:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010382c:	f7 da                	neg    %edx
f010382e:	83 d1 00             	adc    $0x0,%ecx
f0103831:	f7 d9                	neg    %ecx
f0103833:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103836:	b8 0a 00 00 00       	mov    $0xa,%eax
f010383b:	e9 ec 00 00 00       	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, int);
f0103840:	8b 45 14             	mov    0x14(%ebp),%eax
f0103843:	8b 00                	mov    (%eax),%eax
f0103845:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103848:	99                   	cltd   
f0103849:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010384c:	8b 45 14             	mov    0x14(%ebp),%eax
f010384f:	8d 40 04             	lea    0x4(%eax),%eax
f0103852:	89 45 14             	mov    %eax,0x14(%ebp)
f0103855:	eb b4                	jmp    f010380b <.L29+0x3d>

f0103857 <.L23>:
f0103857:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010385a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010385d:	83 f9 01             	cmp    $0x1,%ecx
f0103860:	7f 1e                	jg     f0103880 <.L23+0x29>
	else if (lflag)
f0103862:	85 c9                	test   %ecx,%ecx
f0103864:	74 32                	je     f0103898 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0103866:	8b 45 14             	mov    0x14(%ebp),%eax
f0103869:	8b 10                	mov    (%eax),%edx
f010386b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103870:	8d 40 04             	lea    0x4(%eax),%eax
f0103873:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103876:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010387b:	e9 ac 00 00 00       	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103880:	8b 45 14             	mov    0x14(%ebp),%eax
f0103883:	8b 10                	mov    (%eax),%edx
f0103885:	8b 48 04             	mov    0x4(%eax),%ecx
f0103888:	8d 40 08             	lea    0x8(%eax),%eax
f010388b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010388e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0103893:	e9 94 00 00 00       	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103898:	8b 45 14             	mov    0x14(%ebp),%eax
f010389b:	8b 10                	mov    (%eax),%edx
f010389d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01038a2:	8d 40 04             	lea    0x4(%eax),%eax
f01038a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01038a8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01038ad:	eb 7d                	jmp    f010392c <.L25+0x2b>

f01038af <.L26>:
f01038af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01038b2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01038b5:	83 f9 01             	cmp    $0x1,%ecx
f01038b8:	7f 1b                	jg     f01038d5 <.L26+0x26>
	else if (lflag)
f01038ba:	85 c9                	test   %ecx,%ecx
f01038bc:	74 2c                	je     f01038ea <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01038be:	8b 45 14             	mov    0x14(%ebp),%eax
f01038c1:	8b 10                	mov    (%eax),%edx
f01038c3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01038c8:	8d 40 04             	lea    0x4(%eax),%eax
f01038cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038ce:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f01038d3:	eb 57                	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01038d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01038d8:	8b 10                	mov    (%eax),%edx
f01038da:	8b 48 04             	mov    0x4(%eax),%ecx
f01038dd:	8d 40 08             	lea    0x8(%eax),%eax
f01038e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038e3:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f01038e8:	eb 42                	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01038ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01038ed:	8b 10                	mov    (%eax),%edx
f01038ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01038f4:	8d 40 04             	lea    0x4(%eax),%eax
f01038f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038fa:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f01038ff:	eb 2b                	jmp    f010392c <.L25+0x2b>

f0103901 <.L25>:
f0103901:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0103904:	83 ec 08             	sub    $0x8,%esp
f0103907:	57                   	push   %edi
f0103908:	6a 30                	push   $0x30
f010390a:	ff d6                	call   *%esi
			putch('x', putdat);
f010390c:	83 c4 08             	add    $0x8,%esp
f010390f:	57                   	push   %edi
f0103910:	6a 78                	push   $0x78
f0103912:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103914:	8b 45 14             	mov    0x14(%ebp),%eax
f0103917:	8b 10                	mov    (%eax),%edx
f0103919:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010391e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103921:	8d 40 04             	lea    0x4(%eax),%eax
f0103924:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103927:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010392c:	83 ec 0c             	sub    $0xc,%esp
f010392f:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f0103933:	53                   	push   %ebx
f0103934:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103937:	50                   	push   %eax
f0103938:	51                   	push   %ecx
f0103939:	52                   	push   %edx
f010393a:	89 fa                	mov    %edi,%edx
f010393c:	89 f0                	mov    %esi,%eax
f010393e:	e8 08 fb ff ff       	call   f010344b <printnum>
			break;
f0103943:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0103946:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103949:	83 c3 01             	add    $0x1,%ebx
f010394c:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103950:	83 f8 25             	cmp    $0x25,%eax
f0103953:	0f 84 23 fc ff ff    	je     f010357c <vprintfmt+0x31>
			if (ch == '\0')
f0103959:	85 c0                	test   %eax,%eax
f010395b:	0f 84 97 00 00 00    	je     f01039f8 <.L20+0x23>
			putch(ch, putdat);
f0103961:	83 ec 08             	sub    $0x8,%esp
f0103964:	57                   	push   %edi
f0103965:	50                   	push   %eax
f0103966:	ff d6                	call   *%esi
f0103968:	83 c4 10             	add    $0x10,%esp
f010396b:	eb dc                	jmp    f0103949 <.L25+0x48>

f010396d <.L21>:
f010396d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103970:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0103973:	83 f9 01             	cmp    $0x1,%ecx
f0103976:	7f 1b                	jg     f0103993 <.L21+0x26>
	else if (lflag)
f0103978:	85 c9                	test   %ecx,%ecx
f010397a:	74 2c                	je     f01039a8 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f010397c:	8b 45 14             	mov    0x14(%ebp),%eax
f010397f:	8b 10                	mov    (%eax),%edx
f0103981:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103986:	8d 40 04             	lea    0x4(%eax),%eax
f0103989:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010398c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0103991:	eb 99                	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103993:	8b 45 14             	mov    0x14(%ebp),%eax
f0103996:	8b 10                	mov    (%eax),%edx
f0103998:	8b 48 04             	mov    0x4(%eax),%ecx
f010399b:	8d 40 08             	lea    0x8(%eax),%eax
f010399e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01039a1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01039a6:	eb 84                	jmp    f010392c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01039a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01039ab:	8b 10                	mov    (%eax),%edx
f01039ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01039b2:	8d 40 04             	lea    0x4(%eax),%eax
f01039b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01039b8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01039bd:	e9 6a ff ff ff       	jmp    f010392c <.L25+0x2b>

f01039c2 <.L35>:
f01039c2:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01039c5:	83 ec 08             	sub    $0x8,%esp
f01039c8:	57                   	push   %edi
f01039c9:	6a 25                	push   $0x25
f01039cb:	ff d6                	call   *%esi
			break;
f01039cd:	83 c4 10             	add    $0x10,%esp
f01039d0:	e9 71 ff ff ff       	jmp    f0103946 <.L25+0x45>

f01039d5 <.L20>:
f01039d5:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01039d8:	83 ec 08             	sub    $0x8,%esp
f01039db:	57                   	push   %edi
f01039dc:	6a 25                	push   $0x25
f01039de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01039e0:	83 c4 10             	add    $0x10,%esp
f01039e3:	89 d8                	mov    %ebx,%eax
f01039e5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01039e9:	74 05                	je     f01039f0 <.L20+0x1b>
f01039eb:	83 e8 01             	sub    $0x1,%eax
f01039ee:	eb f5                	jmp    f01039e5 <.L20+0x10>
f01039f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039f3:	e9 4e ff ff ff       	jmp    f0103946 <.L25+0x45>
}
f01039f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039fb:	5b                   	pop    %ebx
f01039fc:	5e                   	pop    %esi
f01039fd:	5f                   	pop    %edi
f01039fe:	5d                   	pop    %ebp
f01039ff:	c3                   	ret    

f0103a00 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103a00:	f3 0f 1e fb          	endbr32 
f0103a04:	55                   	push   %ebp
f0103a05:	89 e5                	mov    %esp,%ebp
f0103a07:	53                   	push   %ebx
f0103a08:	83 ec 14             	sub    $0x14,%esp
f0103a0b:	e8 d0 c7 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0103a10:	81 c3 f8 48 01 00    	add    $0x148f8,%ebx
f0103a16:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a19:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103a1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103a1f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103a23:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103a26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103a2d:	85 c0                	test   %eax,%eax
f0103a2f:	74 2b                	je     f0103a5c <vsnprintf+0x5c>
f0103a31:	85 d2                	test   %edx,%edx
f0103a33:	7e 27                	jle    f0103a5c <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103a35:	ff 75 14             	pushl  0x14(%ebp)
f0103a38:	ff 75 10             	pushl  0x10(%ebp)
f0103a3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103a3e:	50                   	push   %eax
f0103a3f:	8d 83 01 b2 fe ff    	lea    -0x14dff(%ebx),%eax
f0103a45:	50                   	push   %eax
f0103a46:	e8 00 fb ff ff       	call   f010354b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103a4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103a4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a54:	83 c4 10             	add    $0x10,%esp
}
f0103a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a5a:	c9                   	leave  
f0103a5b:	c3                   	ret    
		return -E_INVAL;
f0103a5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103a61:	eb f4                	jmp    f0103a57 <vsnprintf+0x57>

f0103a63 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103a63:	f3 0f 1e fb          	endbr32 
f0103a67:	55                   	push   %ebp
f0103a68:	89 e5                	mov    %esp,%ebp
f0103a6a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103a6d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103a70:	50                   	push   %eax
f0103a71:	ff 75 10             	pushl  0x10(%ebp)
f0103a74:	ff 75 0c             	pushl  0xc(%ebp)
f0103a77:	ff 75 08             	pushl  0x8(%ebp)
f0103a7a:	e8 81 ff ff ff       	call   f0103a00 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103a7f:	c9                   	leave  
f0103a80:	c3                   	ret    

f0103a81 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103a81:	f3 0f 1e fb          	endbr32 
f0103a85:	55                   	push   %ebp
f0103a86:	89 e5                	mov    %esp,%ebp
f0103a88:	57                   	push   %edi
f0103a89:	56                   	push   %esi
f0103a8a:	53                   	push   %ebx
f0103a8b:	83 ec 1c             	sub    $0x1c,%esp
f0103a8e:	e8 4d c7 ff ff       	call   f01001e0 <__x86.get_pc_thunk.bx>
f0103a93:	81 c3 75 48 01 00    	add    $0x14875,%ebx
f0103a99:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103a9c:	85 c0                	test   %eax,%eax
f0103a9e:	74 13                	je     f0103ab3 <readline+0x32>
		cprintf("%s", prompt);
f0103aa0:	83 ec 08             	sub    $0x8,%esp
f0103aa3:	50                   	push   %eax
f0103aa4:	8d 83 81 cb fe ff    	lea    -0x1347f(%ebx),%eax
f0103aaa:	50                   	push   %eax
f0103aab:	e8 22 f6 ff ff       	call   f01030d2 <cprintf>
f0103ab0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103ab3:	83 ec 0c             	sub    $0xc,%esp
f0103ab6:	6a 00                	push   $0x0
f0103ab8:	e8 cd cc ff ff       	call   f010078a <iscons>
f0103abd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103ac0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103ac3:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0103ac8:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0103ace:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103ad1:	eb 51                	jmp    f0103b24 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0103ad3:	83 ec 08             	sub    $0x8,%esp
f0103ad6:	50                   	push   %eax
f0103ad7:	8d 83 bc d0 fe ff    	lea    -0x12f44(%ebx),%eax
f0103add:	50                   	push   %eax
f0103ade:	e8 ef f5 ff ff       	call   f01030d2 <cprintf>
			return NULL;
f0103ae3:	83 c4 10             	add    $0x10,%esp
f0103ae6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103aee:	5b                   	pop    %ebx
f0103aef:	5e                   	pop    %esi
f0103af0:	5f                   	pop    %edi
f0103af1:	5d                   	pop    %ebp
f0103af2:	c3                   	ret    
			if (echoing)
f0103af3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103af7:	75 05                	jne    f0103afe <readline+0x7d>
			i--;
f0103af9:	83 ef 01             	sub    $0x1,%edi
f0103afc:	eb 26                	jmp    f0103b24 <readline+0xa3>
				cputchar('\b');
f0103afe:	83 ec 0c             	sub    $0xc,%esp
f0103b01:	6a 08                	push   $0x8
f0103b03:	e8 59 cc ff ff       	call   f0100761 <cputchar>
f0103b08:	83 c4 10             	add    $0x10,%esp
f0103b0b:	eb ec                	jmp    f0103af9 <readline+0x78>
				cputchar(c);
f0103b0d:	83 ec 0c             	sub    $0xc,%esp
f0103b10:	56                   	push   %esi
f0103b11:	e8 4b cc ff ff       	call   f0100761 <cputchar>
f0103b16:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103b19:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b1c:	89 f0                	mov    %esi,%eax
f0103b1e:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0103b21:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103b24:	e8 4c cc ff ff       	call   f0100775 <getchar>
f0103b29:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103b2b:	85 c0                	test   %eax,%eax
f0103b2d:	78 a4                	js     f0103ad3 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103b2f:	83 f8 08             	cmp    $0x8,%eax
f0103b32:	0f 94 c2             	sete   %dl
f0103b35:	83 f8 7f             	cmp    $0x7f,%eax
f0103b38:	0f 94 c0             	sete   %al
f0103b3b:	08 c2                	or     %al,%dl
f0103b3d:	74 04                	je     f0103b43 <readline+0xc2>
f0103b3f:	85 ff                	test   %edi,%edi
f0103b41:	7f b0                	jg     f0103af3 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103b43:	83 fe 1f             	cmp    $0x1f,%esi
f0103b46:	7e 10                	jle    f0103b58 <readline+0xd7>
f0103b48:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103b4e:	7f 08                	jg     f0103b58 <readline+0xd7>
			if (echoing)
f0103b50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b54:	74 c3                	je     f0103b19 <readline+0x98>
f0103b56:	eb b5                	jmp    f0103b0d <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0103b58:	83 fe 0a             	cmp    $0xa,%esi
f0103b5b:	74 05                	je     f0103b62 <readline+0xe1>
f0103b5d:	83 fe 0d             	cmp    $0xd,%esi
f0103b60:	75 c2                	jne    f0103b24 <readline+0xa3>
			if (echoing)
f0103b62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b66:	75 13                	jne    f0103b7b <readline+0xfa>
			buf[i] = 0;
f0103b68:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0103b6f:	00 
			return buf;
f0103b70:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0103b76:	e9 70 ff ff ff       	jmp    f0103aeb <readline+0x6a>
				cputchar('\n');
f0103b7b:	83 ec 0c             	sub    $0xc,%esp
f0103b7e:	6a 0a                	push   $0xa
f0103b80:	e8 dc cb ff ff       	call   f0100761 <cputchar>
f0103b85:	83 c4 10             	add    $0x10,%esp
f0103b88:	eb de                	jmp    f0103b68 <readline+0xe7>

f0103b8a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103b8a:	f3 0f 1e fb          	endbr32 
f0103b8e:	55                   	push   %ebp
f0103b8f:	89 e5                	mov    %esp,%ebp
f0103b91:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103b94:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b99:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103b9d:	74 05                	je     f0103ba4 <strlen+0x1a>
		n++;
f0103b9f:	83 c0 01             	add    $0x1,%eax
f0103ba2:	eb f5                	jmp    f0103b99 <strlen+0xf>
	return n;
}
f0103ba4:	5d                   	pop    %ebp
f0103ba5:	c3                   	ret    

f0103ba6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103ba6:	f3 0f 1e fb          	endbr32 
f0103baa:	55                   	push   %ebp
f0103bab:	89 e5                	mov    %esp,%ebp
f0103bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103bb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bb8:	39 d0                	cmp    %edx,%eax
f0103bba:	74 0d                	je     f0103bc9 <strnlen+0x23>
f0103bbc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103bc0:	74 05                	je     f0103bc7 <strnlen+0x21>
		n++;
f0103bc2:	83 c0 01             	add    $0x1,%eax
f0103bc5:	eb f1                	jmp    f0103bb8 <strnlen+0x12>
f0103bc7:	89 c2                	mov    %eax,%edx
	return n;
}
f0103bc9:	89 d0                	mov    %edx,%eax
f0103bcb:	5d                   	pop    %ebp
f0103bcc:	c3                   	ret    

f0103bcd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103bcd:	f3 0f 1e fb          	endbr32 
f0103bd1:	55                   	push   %ebp
f0103bd2:	89 e5                	mov    %esp,%ebp
f0103bd4:	53                   	push   %ebx
f0103bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103be0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103be4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103be7:	83 c0 01             	add    $0x1,%eax
f0103bea:	84 d2                	test   %dl,%dl
f0103bec:	75 f2                	jne    f0103be0 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0103bee:	89 c8                	mov    %ecx,%eax
f0103bf0:	5b                   	pop    %ebx
f0103bf1:	5d                   	pop    %ebp
f0103bf2:	c3                   	ret    

f0103bf3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103bf3:	f3 0f 1e fb          	endbr32 
f0103bf7:	55                   	push   %ebp
f0103bf8:	89 e5                	mov    %esp,%ebp
f0103bfa:	53                   	push   %ebx
f0103bfb:	83 ec 10             	sub    $0x10,%esp
f0103bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103c01:	53                   	push   %ebx
f0103c02:	e8 83 ff ff ff       	call   f0103b8a <strlen>
f0103c07:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103c0a:	ff 75 0c             	pushl  0xc(%ebp)
f0103c0d:	01 d8                	add    %ebx,%eax
f0103c0f:	50                   	push   %eax
f0103c10:	e8 b8 ff ff ff       	call   f0103bcd <strcpy>
	return dst;
}
f0103c15:	89 d8                	mov    %ebx,%eax
f0103c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c1a:	c9                   	leave  
f0103c1b:	c3                   	ret    

f0103c1c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103c1c:	f3 0f 1e fb          	endbr32 
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	56                   	push   %esi
f0103c24:	53                   	push   %ebx
f0103c25:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c28:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c2b:	89 f3                	mov    %esi,%ebx
f0103c2d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c30:	89 f0                	mov    %esi,%eax
f0103c32:	39 d8                	cmp    %ebx,%eax
f0103c34:	74 11                	je     f0103c47 <strncpy+0x2b>
		*dst++ = *src;
f0103c36:	83 c0 01             	add    $0x1,%eax
f0103c39:	0f b6 0a             	movzbl (%edx),%ecx
f0103c3c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103c3f:	80 f9 01             	cmp    $0x1,%cl
f0103c42:	83 da ff             	sbb    $0xffffffff,%edx
f0103c45:	eb eb                	jmp    f0103c32 <strncpy+0x16>
	}
	return ret;
}
f0103c47:	89 f0                	mov    %esi,%eax
f0103c49:	5b                   	pop    %ebx
f0103c4a:	5e                   	pop    %esi
f0103c4b:	5d                   	pop    %ebp
f0103c4c:	c3                   	ret    

f0103c4d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103c4d:	f3 0f 1e fb          	endbr32 
f0103c51:	55                   	push   %ebp
f0103c52:	89 e5                	mov    %esp,%ebp
f0103c54:	56                   	push   %esi
f0103c55:	53                   	push   %ebx
f0103c56:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103c5c:	8b 55 10             	mov    0x10(%ebp),%edx
f0103c5f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103c61:	85 d2                	test   %edx,%edx
f0103c63:	74 21                	je     f0103c86 <strlcpy+0x39>
f0103c65:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103c69:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0103c6b:	39 c2                	cmp    %eax,%edx
f0103c6d:	74 14                	je     f0103c83 <strlcpy+0x36>
f0103c6f:	0f b6 19             	movzbl (%ecx),%ebx
f0103c72:	84 db                	test   %bl,%bl
f0103c74:	74 0b                	je     f0103c81 <strlcpy+0x34>
			*dst++ = *src++;
f0103c76:	83 c1 01             	add    $0x1,%ecx
f0103c79:	83 c2 01             	add    $0x1,%edx
f0103c7c:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103c7f:	eb ea                	jmp    f0103c6b <strlcpy+0x1e>
f0103c81:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103c83:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103c86:	29 f0                	sub    %esi,%eax
}
f0103c88:	5b                   	pop    %ebx
f0103c89:	5e                   	pop    %esi
f0103c8a:	5d                   	pop    %ebp
f0103c8b:	c3                   	ret    

f0103c8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103c8c:	f3 0f 1e fb          	endbr32 
f0103c90:	55                   	push   %ebp
f0103c91:	89 e5                	mov    %esp,%ebp
f0103c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103c99:	0f b6 01             	movzbl (%ecx),%eax
f0103c9c:	84 c0                	test   %al,%al
f0103c9e:	74 0c                	je     f0103cac <strcmp+0x20>
f0103ca0:	3a 02                	cmp    (%edx),%al
f0103ca2:	75 08                	jne    f0103cac <strcmp+0x20>
		p++, q++;
f0103ca4:	83 c1 01             	add    $0x1,%ecx
f0103ca7:	83 c2 01             	add    $0x1,%edx
f0103caa:	eb ed                	jmp    f0103c99 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103cac:	0f b6 c0             	movzbl %al,%eax
f0103caf:	0f b6 12             	movzbl (%edx),%edx
f0103cb2:	29 d0                	sub    %edx,%eax
}
f0103cb4:	5d                   	pop    %ebp
f0103cb5:	c3                   	ret    

f0103cb6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103cb6:	f3 0f 1e fb          	endbr32 
f0103cba:	55                   	push   %ebp
f0103cbb:	89 e5                	mov    %esp,%ebp
f0103cbd:	53                   	push   %ebx
f0103cbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cc4:	89 c3                	mov    %eax,%ebx
f0103cc6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103cc9:	eb 06                	jmp    f0103cd1 <strncmp+0x1b>
		n--, p++, q++;
f0103ccb:	83 c0 01             	add    $0x1,%eax
f0103cce:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103cd1:	39 d8                	cmp    %ebx,%eax
f0103cd3:	74 16                	je     f0103ceb <strncmp+0x35>
f0103cd5:	0f b6 08             	movzbl (%eax),%ecx
f0103cd8:	84 c9                	test   %cl,%cl
f0103cda:	74 04                	je     f0103ce0 <strncmp+0x2a>
f0103cdc:	3a 0a                	cmp    (%edx),%cl
f0103cde:	74 eb                	je     f0103ccb <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103ce0:	0f b6 00             	movzbl (%eax),%eax
f0103ce3:	0f b6 12             	movzbl (%edx),%edx
f0103ce6:	29 d0                	sub    %edx,%eax
}
f0103ce8:	5b                   	pop    %ebx
f0103ce9:	5d                   	pop    %ebp
f0103cea:	c3                   	ret    
		return 0;
f0103ceb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cf0:	eb f6                	jmp    f0103ce8 <strncmp+0x32>

f0103cf2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103cf2:	f3 0f 1e fb          	endbr32 
f0103cf6:	55                   	push   %ebp
f0103cf7:	89 e5                	mov    %esp,%ebp
f0103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d00:	0f b6 10             	movzbl (%eax),%edx
f0103d03:	84 d2                	test   %dl,%dl
f0103d05:	74 09                	je     f0103d10 <strchr+0x1e>
		if (*s == c)
f0103d07:	38 ca                	cmp    %cl,%dl
f0103d09:	74 0a                	je     f0103d15 <strchr+0x23>
	for (; *s; s++)
f0103d0b:	83 c0 01             	add    $0x1,%eax
f0103d0e:	eb f0                	jmp    f0103d00 <strchr+0xe>
			return (char *) s;
	return 0;
f0103d10:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d15:	5d                   	pop    %ebp
f0103d16:	c3                   	ret    

f0103d17 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d17:	f3 0f 1e fb          	endbr32 
f0103d1b:	55                   	push   %ebp
f0103d1c:	89 e5                	mov    %esp,%ebp
f0103d1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d25:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103d28:	38 ca                	cmp    %cl,%dl
f0103d2a:	74 09                	je     f0103d35 <strfind+0x1e>
f0103d2c:	84 d2                	test   %dl,%dl
f0103d2e:	74 05                	je     f0103d35 <strfind+0x1e>
	for (; *s; s++)
f0103d30:	83 c0 01             	add    $0x1,%eax
f0103d33:	eb f0                	jmp    f0103d25 <strfind+0xe>
			break;
	return (char *) s;
}
f0103d35:	5d                   	pop    %ebp
f0103d36:	c3                   	ret    

f0103d37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103d37:	f3 0f 1e fb          	endbr32 
f0103d3b:	55                   	push   %ebp
f0103d3c:	89 e5                	mov    %esp,%ebp
f0103d3e:	57                   	push   %edi
f0103d3f:	56                   	push   %esi
f0103d40:	53                   	push   %ebx
f0103d41:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103d44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103d47:	85 c9                	test   %ecx,%ecx
f0103d49:	74 31                	je     f0103d7c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103d4b:	89 f8                	mov    %edi,%eax
f0103d4d:	09 c8                	or     %ecx,%eax
f0103d4f:	a8 03                	test   $0x3,%al
f0103d51:	75 23                	jne    f0103d76 <memset+0x3f>
		c &= 0xFF;
f0103d53:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103d57:	89 d3                	mov    %edx,%ebx
f0103d59:	c1 e3 08             	shl    $0x8,%ebx
f0103d5c:	89 d0                	mov    %edx,%eax
f0103d5e:	c1 e0 18             	shl    $0x18,%eax
f0103d61:	89 d6                	mov    %edx,%esi
f0103d63:	c1 e6 10             	shl    $0x10,%esi
f0103d66:	09 f0                	or     %esi,%eax
f0103d68:	09 c2                	or     %eax,%edx
f0103d6a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103d6c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103d6f:	89 d0                	mov    %edx,%eax
f0103d71:	fc                   	cld    
f0103d72:	f3 ab                	rep stos %eax,%es:(%edi)
f0103d74:	eb 06                	jmp    f0103d7c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103d76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d79:	fc                   	cld    
f0103d7a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103d7c:	89 f8                	mov    %edi,%eax
f0103d7e:	5b                   	pop    %ebx
f0103d7f:	5e                   	pop    %esi
f0103d80:	5f                   	pop    %edi
f0103d81:	5d                   	pop    %ebp
f0103d82:	c3                   	ret    

f0103d83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103d83:	f3 0f 1e fb          	endbr32 
f0103d87:	55                   	push   %ebp
f0103d88:	89 e5                	mov    %esp,%ebp
f0103d8a:	57                   	push   %edi
f0103d8b:	56                   	push   %esi
f0103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103d95:	39 c6                	cmp    %eax,%esi
f0103d97:	73 32                	jae    f0103dcb <memmove+0x48>
f0103d99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103d9c:	39 c2                	cmp    %eax,%edx
f0103d9e:	76 2b                	jbe    f0103dcb <memmove+0x48>
		s += n;
		d += n;
f0103da0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103da3:	89 fe                	mov    %edi,%esi
f0103da5:	09 ce                	or     %ecx,%esi
f0103da7:	09 d6                	or     %edx,%esi
f0103da9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103daf:	75 0e                	jne    f0103dbf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103db1:	83 ef 04             	sub    $0x4,%edi
f0103db4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103db7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103dba:	fd                   	std    
f0103dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103dbd:	eb 09                	jmp    f0103dc8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103dbf:	83 ef 01             	sub    $0x1,%edi
f0103dc2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103dc5:	fd                   	std    
f0103dc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103dc8:	fc                   	cld    
f0103dc9:	eb 1a                	jmp    f0103de5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103dcb:	89 c2                	mov    %eax,%edx
f0103dcd:	09 ca                	or     %ecx,%edx
f0103dcf:	09 f2                	or     %esi,%edx
f0103dd1:	f6 c2 03             	test   $0x3,%dl
f0103dd4:	75 0a                	jne    f0103de0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103dd6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103dd9:	89 c7                	mov    %eax,%edi
f0103ddb:	fc                   	cld    
f0103ddc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103dde:	eb 05                	jmp    f0103de5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0103de0:	89 c7                	mov    %eax,%edi
f0103de2:	fc                   	cld    
f0103de3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103de5:	5e                   	pop    %esi
f0103de6:	5f                   	pop    %edi
f0103de7:	5d                   	pop    %ebp
f0103de8:	c3                   	ret    

f0103de9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103de9:	f3 0f 1e fb          	endbr32 
f0103ded:	55                   	push   %ebp
f0103dee:	89 e5                	mov    %esp,%ebp
f0103df0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103df3:	ff 75 10             	pushl  0x10(%ebp)
f0103df6:	ff 75 0c             	pushl  0xc(%ebp)
f0103df9:	ff 75 08             	pushl  0x8(%ebp)
f0103dfc:	e8 82 ff ff ff       	call   f0103d83 <memmove>
}
f0103e01:	c9                   	leave  
f0103e02:	c3                   	ret    

f0103e03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e03:	f3 0f 1e fb          	endbr32 
f0103e07:	55                   	push   %ebp
f0103e08:	89 e5                	mov    %esp,%ebp
f0103e0a:	56                   	push   %esi
f0103e0b:	53                   	push   %ebx
f0103e0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e12:	89 c6                	mov    %eax,%esi
f0103e14:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e17:	39 f0                	cmp    %esi,%eax
f0103e19:	74 1c                	je     f0103e37 <memcmp+0x34>
		if (*s1 != *s2)
f0103e1b:	0f b6 08             	movzbl (%eax),%ecx
f0103e1e:	0f b6 1a             	movzbl (%edx),%ebx
f0103e21:	38 d9                	cmp    %bl,%cl
f0103e23:	75 08                	jne    f0103e2d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103e25:	83 c0 01             	add    $0x1,%eax
f0103e28:	83 c2 01             	add    $0x1,%edx
f0103e2b:	eb ea                	jmp    f0103e17 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0103e2d:	0f b6 c1             	movzbl %cl,%eax
f0103e30:	0f b6 db             	movzbl %bl,%ebx
f0103e33:	29 d8                	sub    %ebx,%eax
f0103e35:	eb 05                	jmp    f0103e3c <memcmp+0x39>
	}

	return 0;
f0103e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e3c:	5b                   	pop    %ebx
f0103e3d:	5e                   	pop    %esi
f0103e3e:	5d                   	pop    %ebp
f0103e3f:	c3                   	ret    

f0103e40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103e40:	f3 0f 1e fb          	endbr32 
f0103e44:	55                   	push   %ebp
f0103e45:	89 e5                	mov    %esp,%ebp
f0103e47:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103e4d:	89 c2                	mov    %eax,%edx
f0103e4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103e52:	39 d0                	cmp    %edx,%eax
f0103e54:	73 09                	jae    f0103e5f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103e56:	38 08                	cmp    %cl,(%eax)
f0103e58:	74 05                	je     f0103e5f <memfind+0x1f>
	for (; s < ends; s++)
f0103e5a:	83 c0 01             	add    $0x1,%eax
f0103e5d:	eb f3                	jmp    f0103e52 <memfind+0x12>
			break;
	return (void *) s;
}
f0103e5f:	5d                   	pop    %ebp
f0103e60:	c3                   	ret    

f0103e61 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103e61:	f3 0f 1e fb          	endbr32 
f0103e65:	55                   	push   %ebp
f0103e66:	89 e5                	mov    %esp,%ebp
f0103e68:	57                   	push   %edi
f0103e69:	56                   	push   %esi
f0103e6a:	53                   	push   %ebx
f0103e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103e71:	eb 03                	jmp    f0103e76 <strtol+0x15>
		s++;
f0103e73:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103e76:	0f b6 01             	movzbl (%ecx),%eax
f0103e79:	3c 20                	cmp    $0x20,%al
f0103e7b:	74 f6                	je     f0103e73 <strtol+0x12>
f0103e7d:	3c 09                	cmp    $0x9,%al
f0103e7f:	74 f2                	je     f0103e73 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0103e81:	3c 2b                	cmp    $0x2b,%al
f0103e83:	74 2a                	je     f0103eaf <strtol+0x4e>
	int neg = 0;
f0103e85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103e8a:	3c 2d                	cmp    $0x2d,%al
f0103e8c:	74 2b                	je     f0103eb9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103e8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103e94:	75 0f                	jne    f0103ea5 <strtol+0x44>
f0103e96:	80 39 30             	cmpb   $0x30,(%ecx)
f0103e99:	74 28                	je     f0103ec3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103e9b:	85 db                	test   %ebx,%ebx
f0103e9d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ea2:	0f 44 d8             	cmove  %eax,%ebx
f0103ea5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103eaa:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103ead:	eb 46                	jmp    f0103ef5 <strtol+0x94>
		s++;
f0103eaf:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103eb2:	bf 00 00 00 00       	mov    $0x0,%edi
f0103eb7:	eb d5                	jmp    f0103e8e <strtol+0x2d>
		s++, neg = 1;
f0103eb9:	83 c1 01             	add    $0x1,%ecx
f0103ebc:	bf 01 00 00 00       	mov    $0x1,%edi
f0103ec1:	eb cb                	jmp    f0103e8e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ec3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103ec7:	74 0e                	je     f0103ed7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103ec9:	85 db                	test   %ebx,%ebx
f0103ecb:	75 d8                	jne    f0103ea5 <strtol+0x44>
		s++, base = 8;
f0103ecd:	83 c1 01             	add    $0x1,%ecx
f0103ed0:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103ed5:	eb ce                	jmp    f0103ea5 <strtol+0x44>
		s += 2, base = 16;
f0103ed7:	83 c1 02             	add    $0x2,%ecx
f0103eda:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103edf:	eb c4                	jmp    f0103ea5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103ee1:	0f be d2             	movsbl %dl,%edx
f0103ee4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103ee7:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103eea:	7d 3a                	jge    f0103f26 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103eec:	83 c1 01             	add    $0x1,%ecx
f0103eef:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103ef3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103ef5:	0f b6 11             	movzbl (%ecx),%edx
f0103ef8:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103efb:	89 f3                	mov    %esi,%ebx
f0103efd:	80 fb 09             	cmp    $0x9,%bl
f0103f00:	76 df                	jbe    f0103ee1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0103f02:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103f05:	89 f3                	mov    %esi,%ebx
f0103f07:	80 fb 19             	cmp    $0x19,%bl
f0103f0a:	77 08                	ja     f0103f14 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103f0c:	0f be d2             	movsbl %dl,%edx
f0103f0f:	83 ea 57             	sub    $0x57,%edx
f0103f12:	eb d3                	jmp    f0103ee7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0103f14:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103f17:	89 f3                	mov    %esi,%ebx
f0103f19:	80 fb 19             	cmp    $0x19,%bl
f0103f1c:	77 08                	ja     f0103f26 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103f1e:	0f be d2             	movsbl %dl,%edx
f0103f21:	83 ea 37             	sub    $0x37,%edx
f0103f24:	eb c1                	jmp    f0103ee7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103f26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103f2a:	74 05                	je     f0103f31 <strtol+0xd0>
		*endptr = (char *) s;
f0103f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103f2f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103f31:	89 c2                	mov    %eax,%edx
f0103f33:	f7 da                	neg    %edx
f0103f35:	85 ff                	test   %edi,%edi
f0103f37:	0f 45 c2             	cmovne %edx,%eax
}
f0103f3a:	5b                   	pop    %ebx
f0103f3b:	5e                   	pop    %esi
f0103f3c:	5f                   	pop    %edi
f0103f3d:	5d                   	pop    %ebp
f0103f3e:	c3                   	ret    
f0103f3f:	90                   	nop

f0103f40 <__udivdi3>:
f0103f40:	f3 0f 1e fb          	endbr32 
f0103f44:	55                   	push   %ebp
f0103f45:	57                   	push   %edi
f0103f46:	56                   	push   %esi
f0103f47:	53                   	push   %ebx
f0103f48:	83 ec 1c             	sub    $0x1c,%esp
f0103f4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103f4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103f53:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103f57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103f5b:	85 d2                	test   %edx,%edx
f0103f5d:	75 19                	jne    f0103f78 <__udivdi3+0x38>
f0103f5f:	39 f3                	cmp    %esi,%ebx
f0103f61:	76 4d                	jbe    f0103fb0 <__udivdi3+0x70>
f0103f63:	31 ff                	xor    %edi,%edi
f0103f65:	89 e8                	mov    %ebp,%eax
f0103f67:	89 f2                	mov    %esi,%edx
f0103f69:	f7 f3                	div    %ebx
f0103f6b:	89 fa                	mov    %edi,%edx
f0103f6d:	83 c4 1c             	add    $0x1c,%esp
f0103f70:	5b                   	pop    %ebx
f0103f71:	5e                   	pop    %esi
f0103f72:	5f                   	pop    %edi
f0103f73:	5d                   	pop    %ebp
f0103f74:	c3                   	ret    
f0103f75:	8d 76 00             	lea    0x0(%esi),%esi
f0103f78:	39 f2                	cmp    %esi,%edx
f0103f7a:	76 14                	jbe    f0103f90 <__udivdi3+0x50>
f0103f7c:	31 ff                	xor    %edi,%edi
f0103f7e:	31 c0                	xor    %eax,%eax
f0103f80:	89 fa                	mov    %edi,%edx
f0103f82:	83 c4 1c             	add    $0x1c,%esp
f0103f85:	5b                   	pop    %ebx
f0103f86:	5e                   	pop    %esi
f0103f87:	5f                   	pop    %edi
f0103f88:	5d                   	pop    %ebp
f0103f89:	c3                   	ret    
f0103f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f90:	0f bd fa             	bsr    %edx,%edi
f0103f93:	83 f7 1f             	xor    $0x1f,%edi
f0103f96:	75 48                	jne    f0103fe0 <__udivdi3+0xa0>
f0103f98:	39 f2                	cmp    %esi,%edx
f0103f9a:	72 06                	jb     f0103fa2 <__udivdi3+0x62>
f0103f9c:	31 c0                	xor    %eax,%eax
f0103f9e:	39 eb                	cmp    %ebp,%ebx
f0103fa0:	77 de                	ja     f0103f80 <__udivdi3+0x40>
f0103fa2:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fa7:	eb d7                	jmp    f0103f80 <__udivdi3+0x40>
f0103fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fb0:	89 d9                	mov    %ebx,%ecx
f0103fb2:	85 db                	test   %ebx,%ebx
f0103fb4:	75 0b                	jne    f0103fc1 <__udivdi3+0x81>
f0103fb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fbb:	31 d2                	xor    %edx,%edx
f0103fbd:	f7 f3                	div    %ebx
f0103fbf:	89 c1                	mov    %eax,%ecx
f0103fc1:	31 d2                	xor    %edx,%edx
f0103fc3:	89 f0                	mov    %esi,%eax
f0103fc5:	f7 f1                	div    %ecx
f0103fc7:	89 c6                	mov    %eax,%esi
f0103fc9:	89 e8                	mov    %ebp,%eax
f0103fcb:	89 f7                	mov    %esi,%edi
f0103fcd:	f7 f1                	div    %ecx
f0103fcf:	89 fa                	mov    %edi,%edx
f0103fd1:	83 c4 1c             	add    $0x1c,%esp
f0103fd4:	5b                   	pop    %ebx
f0103fd5:	5e                   	pop    %esi
f0103fd6:	5f                   	pop    %edi
f0103fd7:	5d                   	pop    %ebp
f0103fd8:	c3                   	ret    
f0103fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fe0:	89 f9                	mov    %edi,%ecx
f0103fe2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103fe7:	29 f8                	sub    %edi,%eax
f0103fe9:	d3 e2                	shl    %cl,%edx
f0103feb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103fef:	89 c1                	mov    %eax,%ecx
f0103ff1:	89 da                	mov    %ebx,%edx
f0103ff3:	d3 ea                	shr    %cl,%edx
f0103ff5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103ff9:	09 d1                	or     %edx,%ecx
f0103ffb:	89 f2                	mov    %esi,%edx
f0103ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104001:	89 f9                	mov    %edi,%ecx
f0104003:	d3 e3                	shl    %cl,%ebx
f0104005:	89 c1                	mov    %eax,%ecx
f0104007:	d3 ea                	shr    %cl,%edx
f0104009:	89 f9                	mov    %edi,%ecx
f010400b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010400f:	89 eb                	mov    %ebp,%ebx
f0104011:	d3 e6                	shl    %cl,%esi
f0104013:	89 c1                	mov    %eax,%ecx
f0104015:	d3 eb                	shr    %cl,%ebx
f0104017:	09 de                	or     %ebx,%esi
f0104019:	89 f0                	mov    %esi,%eax
f010401b:	f7 74 24 08          	divl   0x8(%esp)
f010401f:	89 d6                	mov    %edx,%esi
f0104021:	89 c3                	mov    %eax,%ebx
f0104023:	f7 64 24 0c          	mull   0xc(%esp)
f0104027:	39 d6                	cmp    %edx,%esi
f0104029:	72 15                	jb     f0104040 <__udivdi3+0x100>
f010402b:	89 f9                	mov    %edi,%ecx
f010402d:	d3 e5                	shl    %cl,%ebp
f010402f:	39 c5                	cmp    %eax,%ebp
f0104031:	73 04                	jae    f0104037 <__udivdi3+0xf7>
f0104033:	39 d6                	cmp    %edx,%esi
f0104035:	74 09                	je     f0104040 <__udivdi3+0x100>
f0104037:	89 d8                	mov    %ebx,%eax
f0104039:	31 ff                	xor    %edi,%edi
f010403b:	e9 40 ff ff ff       	jmp    f0103f80 <__udivdi3+0x40>
f0104040:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104043:	31 ff                	xor    %edi,%edi
f0104045:	e9 36 ff ff ff       	jmp    f0103f80 <__udivdi3+0x40>
f010404a:	66 90                	xchg   %ax,%ax
f010404c:	66 90                	xchg   %ax,%ax
f010404e:	66 90                	xchg   %ax,%ax

f0104050 <__umoddi3>:
f0104050:	f3 0f 1e fb          	endbr32 
f0104054:	55                   	push   %ebp
f0104055:	57                   	push   %edi
f0104056:	56                   	push   %esi
f0104057:	53                   	push   %ebx
f0104058:	83 ec 1c             	sub    $0x1c,%esp
f010405b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010405f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104063:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104067:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010406b:	85 c0                	test   %eax,%eax
f010406d:	75 19                	jne    f0104088 <__umoddi3+0x38>
f010406f:	39 df                	cmp    %ebx,%edi
f0104071:	76 5d                	jbe    f01040d0 <__umoddi3+0x80>
f0104073:	89 f0                	mov    %esi,%eax
f0104075:	89 da                	mov    %ebx,%edx
f0104077:	f7 f7                	div    %edi
f0104079:	89 d0                	mov    %edx,%eax
f010407b:	31 d2                	xor    %edx,%edx
f010407d:	83 c4 1c             	add    $0x1c,%esp
f0104080:	5b                   	pop    %ebx
f0104081:	5e                   	pop    %esi
f0104082:	5f                   	pop    %edi
f0104083:	5d                   	pop    %ebp
f0104084:	c3                   	ret    
f0104085:	8d 76 00             	lea    0x0(%esi),%esi
f0104088:	89 f2                	mov    %esi,%edx
f010408a:	39 d8                	cmp    %ebx,%eax
f010408c:	76 12                	jbe    f01040a0 <__umoddi3+0x50>
f010408e:	89 f0                	mov    %esi,%eax
f0104090:	89 da                	mov    %ebx,%edx
f0104092:	83 c4 1c             	add    $0x1c,%esp
f0104095:	5b                   	pop    %ebx
f0104096:	5e                   	pop    %esi
f0104097:	5f                   	pop    %edi
f0104098:	5d                   	pop    %ebp
f0104099:	c3                   	ret    
f010409a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01040a0:	0f bd e8             	bsr    %eax,%ebp
f01040a3:	83 f5 1f             	xor    $0x1f,%ebp
f01040a6:	75 50                	jne    f01040f8 <__umoddi3+0xa8>
f01040a8:	39 d8                	cmp    %ebx,%eax
f01040aa:	0f 82 e0 00 00 00    	jb     f0104190 <__umoddi3+0x140>
f01040b0:	89 d9                	mov    %ebx,%ecx
f01040b2:	39 f7                	cmp    %esi,%edi
f01040b4:	0f 86 d6 00 00 00    	jbe    f0104190 <__umoddi3+0x140>
f01040ba:	89 d0                	mov    %edx,%eax
f01040bc:	89 ca                	mov    %ecx,%edx
f01040be:	83 c4 1c             	add    $0x1c,%esp
f01040c1:	5b                   	pop    %ebx
f01040c2:	5e                   	pop    %esi
f01040c3:	5f                   	pop    %edi
f01040c4:	5d                   	pop    %ebp
f01040c5:	c3                   	ret    
f01040c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01040cd:	8d 76 00             	lea    0x0(%esi),%esi
f01040d0:	89 fd                	mov    %edi,%ebp
f01040d2:	85 ff                	test   %edi,%edi
f01040d4:	75 0b                	jne    f01040e1 <__umoddi3+0x91>
f01040d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01040db:	31 d2                	xor    %edx,%edx
f01040dd:	f7 f7                	div    %edi
f01040df:	89 c5                	mov    %eax,%ebp
f01040e1:	89 d8                	mov    %ebx,%eax
f01040e3:	31 d2                	xor    %edx,%edx
f01040e5:	f7 f5                	div    %ebp
f01040e7:	89 f0                	mov    %esi,%eax
f01040e9:	f7 f5                	div    %ebp
f01040eb:	89 d0                	mov    %edx,%eax
f01040ed:	31 d2                	xor    %edx,%edx
f01040ef:	eb 8c                	jmp    f010407d <__umoddi3+0x2d>
f01040f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01040f8:	89 e9                	mov    %ebp,%ecx
f01040fa:	ba 20 00 00 00       	mov    $0x20,%edx
f01040ff:	29 ea                	sub    %ebp,%edx
f0104101:	d3 e0                	shl    %cl,%eax
f0104103:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104107:	89 d1                	mov    %edx,%ecx
f0104109:	89 f8                	mov    %edi,%eax
f010410b:	d3 e8                	shr    %cl,%eax
f010410d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104111:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104115:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104119:	09 c1                	or     %eax,%ecx
f010411b:	89 d8                	mov    %ebx,%eax
f010411d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104121:	89 e9                	mov    %ebp,%ecx
f0104123:	d3 e7                	shl    %cl,%edi
f0104125:	89 d1                	mov    %edx,%ecx
f0104127:	d3 e8                	shr    %cl,%eax
f0104129:	89 e9                	mov    %ebp,%ecx
f010412b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010412f:	d3 e3                	shl    %cl,%ebx
f0104131:	89 c7                	mov    %eax,%edi
f0104133:	89 d1                	mov    %edx,%ecx
f0104135:	89 f0                	mov    %esi,%eax
f0104137:	d3 e8                	shr    %cl,%eax
f0104139:	89 e9                	mov    %ebp,%ecx
f010413b:	89 fa                	mov    %edi,%edx
f010413d:	d3 e6                	shl    %cl,%esi
f010413f:	09 d8                	or     %ebx,%eax
f0104141:	f7 74 24 08          	divl   0x8(%esp)
f0104145:	89 d1                	mov    %edx,%ecx
f0104147:	89 f3                	mov    %esi,%ebx
f0104149:	f7 64 24 0c          	mull   0xc(%esp)
f010414d:	89 c6                	mov    %eax,%esi
f010414f:	89 d7                	mov    %edx,%edi
f0104151:	39 d1                	cmp    %edx,%ecx
f0104153:	72 06                	jb     f010415b <__umoddi3+0x10b>
f0104155:	75 10                	jne    f0104167 <__umoddi3+0x117>
f0104157:	39 c3                	cmp    %eax,%ebx
f0104159:	73 0c                	jae    f0104167 <__umoddi3+0x117>
f010415b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010415f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104163:	89 d7                	mov    %edx,%edi
f0104165:	89 c6                	mov    %eax,%esi
f0104167:	89 ca                	mov    %ecx,%edx
f0104169:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010416e:	29 f3                	sub    %esi,%ebx
f0104170:	19 fa                	sbb    %edi,%edx
f0104172:	89 d0                	mov    %edx,%eax
f0104174:	d3 e0                	shl    %cl,%eax
f0104176:	89 e9                	mov    %ebp,%ecx
f0104178:	d3 eb                	shr    %cl,%ebx
f010417a:	d3 ea                	shr    %cl,%edx
f010417c:	09 d8                	or     %ebx,%eax
f010417e:	83 c4 1c             	add    $0x1c,%esp
f0104181:	5b                   	pop    %ebx
f0104182:	5e                   	pop    %esi
f0104183:	5f                   	pop    %edi
f0104184:	5d                   	pop    %ebp
f0104185:	c3                   	ret    
f0104186:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010418d:	8d 76 00             	lea    0x0(%esi),%esi
f0104190:	29 fe                	sub    %edi,%esi
f0104192:	19 c3                	sbb    %eax,%ebx
f0104194:	89 f2                	mov    %esi,%edx
f0104196:	89 d9                	mov    %ebx,%ecx
f0104198:	e9 1d ff ff ff       	jmp    f01040ba <__umoddi3+0x6a>
