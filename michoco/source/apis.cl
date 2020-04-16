
private/MICHOCOEXCEPTION :: -10

// New API functions
[choco/michocoSolve(pb:Problem,timeLimit:integer,nodeLimit:integer,backtrackLimit:integer) : boolean
 -> let worldNum := world?(),
 		l:list[AbstractBranching] := makeDefaultBranchingList(pb),
 		algo := makeGlobalSearchSolver(true, l)
    in (try (attach(algo,pb),
	        setMaxSolutionStorage(algo,MAXINT),
	        setTimeLimit(algo,timeLimit),
	        setNodeLimit(algo,nodeLimit),
	        setBacktrackLimit(algo,backtrackLimit),
	        
	        newTreeSearch(algo),
		    let pb := algo.problem, feasibleRootState := true in
		       (try propagate(pb)
		        catch contradiction feasibleRootState := false,
		        if feasibleRootState
		          (try (pushWorld(pb),
		                explore(algo.branchingComponents[1],1))
		           catch contradiction popWorld(pb))),
		    endTreeSearch(algo),
	        
	        getFeasibility(algo))
	    catch any (//[MICHOCOEXCEPTION] *** !!! ~S !!! // exception!(),
	    			backtrack(worldNum),
					try time_get() catch any none,
					false))]

//
[choco/michocoMaximize(pb:Problem,obj:IntVar,timeLimit:integer,nodeLimit:integer,backtrackLimit:integer,restart:boolean) : integer
 -> let worldNum := world?(),
 		l:list[AbstractBranching] := makeDefaultBranchingList(pb),
 		algo := makeGlobalSearchMaximizer(obj, restart, l)
    in (try (attach(algo,pb),
	        setMaxSolutionStorage(algo,MAXINT),
	        setTimeLimit(algo,timeLimit),
	        setNodeLimit(algo,nodeLimit),
	        setBacktrackLimit(algo,backtrackLimit),
	        
	        newTreeSearch(algo),
		    let pb := algo.problem, feasibleRootState := true in
		       (try propagate(pb)
		        catch contradiction feasibleRootState := false,
		        if feasibleRootState
		          (try (pushWorld(pb),
		                explore(algo.branchingComponents[1],1))
		           catch contradiction popWorld(pb))),
		    endTreeSearch(algo),
	        
	        getBestObjectiveValue(algo))
	    catch any (//[MICHOCOEXCEPTION] *** !!! ~S !!! // exception!(),
	    			backtrack(worldNum),
					try time_get() catch any none,
					 -1))]

//
[choco/michocoMaximize(pb:Problem,obj:IntVar,timeLimit:integer,nodeLimit:integer,backtrackLimit:integer) : integer
=> choco/michocoMaximize(pb,obj,timeLimit,nodeLimit,backtrackLimit,false)]

//
[choco/michocoMinimize(pb:Problem,obj:IntVar,timeLimit:integer,nodeLimit:integer,backtrackLimit:integer,restart:boolean) : integer
 -> let worldNum := world?(),
 		l:list[AbstractBranching] := makeDefaultBranchingList(pb),
 		algo := makeGlobalSearchMinimizer(obj, restart, l)
    in (try (attach(algo,pb),
	        setMaxSolutionStorage(algo,MAXINT),
	        setTimeLimit(algo,timeLimit),
	        setNodeLimit(algo,nodeLimit),
	        setBacktrackLimit(algo,backtrackLimit),
	        
	        newTreeSearch(algo),
		    let pb := algo.problem, feasibleRootState := true in
		       (try propagate(pb)
		        catch contradiction feasibleRootState := false,
		        if feasibleRootState
		          (try (pushWorld(pb),
		                explore(algo.branchingComponents[1],1))
		           catch contradiction popWorld(pb))),
		    endTreeSearch(algo),
	        
	        getBestObjectiveValue(algo))
	    catch any (//[MICHOCOEXCEPTION] *** !!! ~S !!! // exception!(),
	    			backtrack(worldNum),
					try time_get() catch any none,
					 -1))]

//
[choco/michocoMinimize(pb:Problem,obj:IntVar,timeLimit:integer,nodeLimit:integer,backtrackLimit:integer) : integer
=> choco/michocoMinimize(pb,obj,timeLimit,nodeLimit,backtrackLimit,false)]

//
[choco/getSolutionsNumber(self:Problem) : integer -> getGlobalSearchSolver(self).choco/nbSol]

private/MISOLUTION[key:string] : (integer U {false}) := false

//
[choco/initUnicSolution() : void -> erase(MISOLUTION)]

// 
[choco/miRestoreSolutionIfUnic(p:Problem,solIndex:integer) : boolean
 -> let solutions := getGlobalSearchSolver(p).solutions
 	in (if (solIndex > 0 & length(solutions) >= solIndex)
		let s := solutions[solIndex],
			lval := s.lval,
			nbv := length(lval),
			key := make_string(nbv,'0') in
 			(for iv in (1 .. nbv) (if (known?(lval[iv]) & lval[iv] > 0) key[iv] := '1'),
			if MISOLUTION[key] false
			else
 				let a := s.algo,
        			lvar := (if a.varsToStore a.varsToStore else a.problem.vars)
        		in (for i in (1 .. nbv)
			         (if (lval[i] != unknown)
			             lvar[i].value := lval[i]),
			        MISOLUTION[key] := solIndex,
			        true))
 		else false)]

// 
[choco/miRestoreSolution(p:Problem,solIndex:integer) : boolean
 -> let solutions := getGlobalSearchSolver(p).solutions
 	in (if (solIndex > 0 & length(solutions) >= solIndex)
			let s := solutions[solIndex],
				lval := s.lval,
				nbv := length(lval),
				a := s.algo,
	    		lvar := (if a.varsToStore a.varsToStore else a.problem.vars)
			in (for i in (1 .. nbv)
			    	(if (lval[i] != unknown) lvar[i].value := lval[i]),
			    true) else false)]

//
[choco/miRestoreSolution(s:choco/Solution) : void
 -> let a := s.algo,
        lvar := (if a.varsToStore a.varsToStore else a.problem.vars),
        lval := s.lval,
        nbv := length(lvar) in        // v0.28: size vs. length
     (for i in (1 .. nbv)
         (if (lval[i] != unknown)
             lvar[i].value := lval[i]))]
