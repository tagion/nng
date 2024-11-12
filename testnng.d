
import std.stdio;
import std.array;
import std.range;
import std.conv;

import nngd;


int main(string[] args){
    
    auto log = stderr;
    NNGTestSuite nt = new NNGTestSuite(&log, nngtestflag.DEBUG);
    
    if(args.length > 1) {
        auto no = to!int(args[1]);
        nt.runonce(no);
    } else {
        nt.run();
    }

    auto er = nt.errors();
    
    if(er !is null){
        log.writeln(er);
        return -1;
    }

    log.writeln("Passed!");
    return 0;
    
}


