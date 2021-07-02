@def title = "IBMQJulia.jl"
@def date = Date(2020, 10, 31)

### ॐ पूर्णमदः पूर्णमिदं पूर्णात्पूर्णमुदच्यते ।
### पूर्णस्य पूर्णमादाय पूर्णमेवावशिष्यते ॥
### ॐ शान्तिः शान्तिः शान्तिः ॥

###### _Infinity gives ∞, adding ∞ gives ∞ and substraction of ∞ is also ∞. Let the peace live._
---
The ~~~<a href="https://github.com/Sov-trotter/IBMQJulia.jl">IBMQJulia.jl</a>~~~ package came out of the desire to support the  ~~~<a href="https://quantum-computing.ibm.com/">IBM Quantum Experience(IBMQ)</a>~~~ interface in native Julia for the ~~~<a href="https://github.com/QuantumBFS">Yao/QuantumBFS</a>~~~ ecosystem. The IBMQ interface allows researchers to run quatum circuits on the quantum hardware built by IBM realtime via cloud. 

While Julia's own quantum circuit simulator, ~~~<a href="https://github.com/QuantumBFS/Yao.jl">Yao.jl</a>~~~ has grown in all directions, it was needed to support running larger Yao based circuits on real hardware. IBMQ only supports two ways of running circuits, i.e. the circuit composer on IBMQ and via a REST API. We made use of the JuliaWeb framework, viz. ~~~<a href="https://github.com/JuliaWeb/HTTP.jl">HTTP.jl</a>~~~ for API requests and ~~~<a href="https://github.com/JuliaIO/JSON.jl">JSON.jl</a>~~~ for parsing the data. 

The package implements the following methods:
* The login method, 
`authenticate(token::String)`

```julia
user = authenticate(token)
Logging You in...✔
IBMQUser("......")
```

* A `Yao.AbstractRegister` type viz. `IBMQReg` that holds vital info regarding communication with the IBMQ backend, 
`createreg(user::IBMQUser)`

Here one selects the hardware on which it is desired to run circuit.
```julia
reg = createreg(user)
Fetching Backends...✔
The following backends are available > 
(1, "ibmq_qasm_simulator")
(2, "ibmqx2")
(3, "ibmq_16_melbourne")
(4, "ibmq_vigo")
(5, "ibmq_ourense")
(6, "ibmq_valencia")
(7, "ibmq_armonk")
(8, "ibmq_athens")
(9, "ibmq_santiago")
Enter the serial number of the backend you wish to use
9
n_qubits = 5
basis_gates=Any["id", "u1", "u2", "u3", "cx"]
Confirm? (Y/N)
y
IBMQJulia.IBMQReg{Int64}
    active qubits: 5/5
```
* Yao inherently uses the `apply!()` method to run circuits on a `AbstractRegister` type. Here also we use the same method to apply our circuit to the `IBMQReg`, 
`apply!(reg::IBMQReg, qc::Array{AbstractBlock})`

This creates a IBMQJob type, that holds the session info, register and the circuit
```julia
job = apply!(reg, [qc])
Connecting to ibmq_santiago...✔
Preparing Data...✔
Uploading circuit to ibmq_santiago...✔
Notifying backend...✔
IBMQJulia.Job(IBMQJulia.IBMQReg{Int64}
    active qubits: 5/5, IBMQJulia.Qobj(Dict{String,Any}("qobj_id" => "foo","experiments" => Dict{String,Any}[Dict("instructions" => Any[Dict{String,Any}("name" => "x","qubits" => [0]), Dict{String,Any}("name" => "y","qubits" => [1]), Dict{String,Any}("name" => "z","qubits" => [2]), Dict{String,Any}("name" => "t","qubits" => [1]), Dict{String,Any}("name" => "swap","qubits" => [0, 1]), Dict{String,Any}("name" => "u3","params" => [0.7, 0.0, 0.0],"qubits" => [2]), Dict{String,Any}("name" => "cy","qubits" => [1, 0]), Dict{String,Any}("name" => "cz","qubits" => [2, 1])],"header" => Dict{String,Any}("clbit_labels" => Array{Any,1}[["c", 0], ["c", 1]],"qubit_labels" => Array{Any,1}[["q", 0], ["q", 1], ["q", 2]],"memory_slots" => 1,"n_qubits" => 3),"config" => Dict{Any,Any}())],"header" => Dict("backend_name" => "ibmq_santiago","description" => "Set of Experiments 1"),"config" => Dict{String,Integer}("memory_slots" => 1,"shots" => 1024,"init_qubits" => true),"schema_version" => "1.0.0","type" => "QASM")), "5f9b2b7a8110040012d4451b")


```

There's a bunch of stuff that happens in here. Let's take a closer look. First the API fetches the link for the `ibmq_santiago` backend. The second step is the most important step in the entire package as it is something that has been revised over more than three times to accomodate all the edge cases and to make it a bit fast. 

Yao stores it's circuits in the form of an AST(Abstract Syntax Tree), ~~~<br>~~~viz. `Yao Quantum Block Intermediate Representation(QBIR)`

~~~<img src="https://docs.yaoquantum.org/dev/assets/images/YaoFramework.png">~~~

while the IBMQ hardware runs on `Open Quantum Assembly Language(OpenQASM)`. Also the IBMQ server accepts a special JSON object viz. the `QObj` to hold the circuit information in the JSON request. 
What we needed here was a conversion method from Yao QBIR to QObj, for which we implemented this ~~~<a href="https://arxiv.org/abs/1809.03452">paper</a>~~~, that specifies the Oobj requirements.
The process involved flattening the QBIR and porting the blocks to QASM type. 

* Once the job is uploaded, the time take to run the circuit may depend on the complexity of the cirucit and the backend load. One can check it via the `status()` method,
`stat = status(job::IBMQJob)`

The possible return values are, `COMPLETED`, `VALIDATING`, `QUEUED`, `RUNNING`, `ERROR_VALIDATING_JOB`, `ERROR_RUNNING_JOB`
```julia
status(job)
"VALIDATING"

status(job)
"QUEUED"

status(job)
"RUNNING"

status(job)
"COMPLETED"
```

* Now that we know that the job status is `COMPLETED`, we can download the results.
`getresult(job::IBMQJob)`

One must have applied the `measure` block to get some concrete readings.
```julia
res = getresult(job)
Connecting to ibmq_qasm_simulator...✔
Fetching result from ibmq_qasm_simulator...✔
1-element Array{Any,1}:
 Dict{String,Any}("time_taken" => 0.001423168,"header" => Dict{String,Any}("clbit_labels" => Any[Any["c", 0], Any["c", 1]],"qubit_labels" => Any[Any["q", 0]],"memory_slots" => 1,"n_qubits" => 1),"status" => "DONE","success" => true,"data" => Dict{String,Any}("counts" => Dict{String,Any}("0x0" => 1024)),"metadata" => Dict{String,Any}("fusion" => Dict{String,Any}("enabled" => false),"method" => "stabilizer","measure_sampling" => true,"parallel_state_update" => 16,"parallel_shots" => 1),"shots" => 1024,"seed_simulator" => 301089120)
```
