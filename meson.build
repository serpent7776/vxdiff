project('vxdiff', 'c',
        version : '0.1.0',
        default_options : [
          'warning_level=3',
          'c_std=c11'
        ])

spng_dep = dependency('spng', required : true)

src_files = [
  'main.c'
]

asm_files = [
  'vxdiff.asm'
]

asm_compiler = find_program('nasm', required : true)

asm_objects = custom_target('vxdiff_asm',
                            input : asm_files,
                            output : 'vxdiff.o',
                            command : [asm_compiler, '-g', '-f', 'elf64', '@INPUT@', '-o', '@OUTPUT@'])

compile_args = []

executable('vxdiff',
           src_files + [asm_objects],
           dependencies : [spng_dep],
           c_args : compile_args,
           install : true)
