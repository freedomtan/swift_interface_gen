import ODIE

var opts = Compiler.Options()
opts.targetSpecification = Compiler.TargetSpecification(
    targetTriple: "arm64-apple-macosx27.0",
    targetSOC: "T6020"
)
print(opts)

let layout = Tensor.Layout(
    shape: [1, 3, 224, 224],
    scalarType: .float32,
    strides: nil, interleave: nil, ordering: nil
)

print(layout)
