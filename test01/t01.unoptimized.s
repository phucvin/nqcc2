
    .section .rodata
    .balign 1
  .Lstring.6:
	.asciz "Hello\054\040world\041"
	.globl main

    .text
main:
    pushq %rbp
    movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movl $2, %ebx
	movl $3, %r9d
	addl %r9d, %ebx
	leaq .Lstring.6(%rip), %rdi
	call puts@PLT
	movl %ebx, %eax
	popq %rbx

    movq %rbp, %rsp
    popq %rbp
    ret
	movl $0, %eax
	popq %rbx

    movq %rbp, %rsp
    popq %rbp
    ret
	.section .note.GNU-stack,"",@progbits
