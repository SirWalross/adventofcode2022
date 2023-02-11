data ← ⊃⎕NGET 'input' 1
SolutionA ← +/((⎕C⎕A),⎕A)⍳{⊃(2÷⍨⍴⍵)(↑∩↓)⍵}¨
SolutionB ← +/((⎕C⎕A),⎕A)⍳{⊃¨ ∩/((3÷⍨⍴⍵),3)⍴⍵}