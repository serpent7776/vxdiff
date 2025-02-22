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

compile_args = []

executable('vxdiff',
           src_files,
           dependencies : [spng_dep],
           c_args : compile_args,
           install : true)
