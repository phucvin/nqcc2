
    .section .rodata
    .balign 1
  .Lstring.6:
	.asciz "Hello\054\040world\041"
	.globl main

    .text
main:
    pushq %rbp
    movq %rsp, %rbp
	subq $0, %rsp
	leaq .Lstring.6(%rip), %rdi
	call puts@PLT
	movl $5, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
	.section .note.GNU-stack,"",@progbits
