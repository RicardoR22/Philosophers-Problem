
import Dispatch

let numberOfPhilosophers = 4

struct ForkPair {
    static let forks: [DispatchSemaphore] = Array(repeating: DispatchSemaphore(value: 1), count: numberOfPhilosophers)
    
    let leftFork: DispatchSemaphore
    let rightFork: DispatchSemaphore
    
    init(leftIndex: Int, rightIndex: Int) {
        //Order forks by index to prevent deadlock
        if leftIndex > rightIndex {
            leftFork = ForkPair.forks[leftIndex]
            rightFork = ForkPair.forks[rightIndex]
        } else {
            leftFork = ForkPair.forks[rightIndex]
            rightFork = ForkPair.forks[leftIndex]
        }
    }
    
    func pickUp() {
        //Acquire by starting with the lower index
        leftFork.wait()
        rightFork.wait()
    }
    
    func putDown() {
        //The order does not matter here
        leftFork.signal()
        rightFork.signal()
    }
}

struct Philosophers {
    let forkPair: ForkPair
    let philosopherIndex: Int
    
    var leftIndex = -1
    var rightIndex = -1
    
    init(philosopherIndex: Int) {
        leftIndex = philosopherIndex
        rightIndex = philosopherIndex - 1
        
        if rightIndex < 0 {
            rightIndex += numberOfPhilosophers
        }
        
        self.forkPair = ForkPair(leftIndex: leftIndex, rightIndex: rightIndex)
        self.philosopherIndex = philosopherIndex
        
        print("Philosopher \(philosopherIndex) picked up fork\(leftIndex) and fork\(rightIndex)")
    }
    
    func run() {
        while true {
            print("Philosopher \(philosopherIndex) is waiting for forks \(leftIndex) and \(rightIndex)")
            forkPair.pickUp()
            print("Philosopher \(philosopherIndex) started eating")
            sleep(3)
            print("Philosopher \(philosopherIndex) stopped eating. Stopped using fork \(leftIndex) and \(rightIndex)")
            forkPair.putDown()
        }
    }
}


let globalSem = DispatchSemaphore(value: 0)

for i in 0..<numberOfPhilosophers {
    if #available(macOS 10.10, *) {
        DispatchQueue.global(qos: .background).async {
            let p = Philosophers(philosopherIndex: i)
            
            p.run()
        }
    }
}

//Start the thread signaling the semaphore
for semaphore in ForkPair.forks {
    semaphore.signal()
}

//Wait forever
globalSem.wait()
