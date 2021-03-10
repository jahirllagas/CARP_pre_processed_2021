struct cvrpInstance #<: AbstractInstance
    N_NODES ::Int64 #vertices
    ARISTAS_REQ ::Int64 #vertices
    ARISTAS_NREQ ::Int64 #vertices
    VEHICLE ::Int64 #vertices
    CAPACITY ::Int64
    COSTE_TOTAL_REQ::Int64
    COST ::Array
    EDGES ::Array 
    DEMAND ::Array
    
    

    function cvrpInstance(filename::String)

        f = open(filename)
        s = read(f, String)
        COST=[]
        DEMAND=[]
        EDGES=[]
        values = split(s,"\n")
        N_NODES = parse(Int64, split(values[3],":")[2])
        ARISTAS_REQ = parse(Int64, split(values[4],":")[2])
        ARISTAS_NREQ = parse(Int64, split(values[5],":")[2])
        VEHICLE= parse(Int64, split(values[6],":")[2])
        CAPACITY= parse(Int64, split(values[7],":")[2])
        COSTE_TOTAL_REQ = parse(Int64, split(values[9],":")[2])
        for i in 1:ARISTAS_REQ
            line_clear=replace(values[10+i]," " => "") 
            line_replace=replace(line_clear,"coste" => ';')
            line_replace=replace(line_replace,"demanda" => ';')
            line=split(line_replace,";")
            append!(COST,parse(Int64,line[2]))
            append!(DEMAND,parse(Int64,line[3]))
            xy=replace(line[1],['(',')'] => "")
            xy_n=split(xy,",")

            x=parse.(Int64,xy_n[1])
            y=parse.(Int64,xy_n[2])
            append!(EDGES,[[x,y]])
            
        end
        if ARISTAS_NREQ==0
            new(N_NODES, ARISTAS_REQ, ARISTAS_NREQ, VEHICLE, CAPACITY, COSTE_TOTAL_REQ, COST, EDGES,DEMAND)
        else
            for i in (ARISTAS_REQ+2):(ARISTAS_REQ+2+ARISTAS_NREQ-1)
                line_clear=replace(values[10+i]," " => "")
                line_replace=replace(line_clear,"coste" => ';')
                line=split(line_replace,";")
                append!(COST,parse(Int64,line[2]))
                xy=replace(line[1],['(',')'] => "")
                xy_n=split(xy,",")
    
                x=parse.(Int64,xy_n[1])
                y=parse.(Int64,xy_n[2])
                append!(EDGES,[[x,y]])
                
            end
            #println(EDGES)
            new(N_NODES, ARISTAS_REQ, ARISTAS_NREQ, VEHICLE, CAPACITY, COSTE_TOTAL_REQ, COST, EDGES,DEMAND)
        end
    end
end

################################################################################


