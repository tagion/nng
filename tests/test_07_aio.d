import std.stdio;
import std.conv;
import std.string;
import std.concurrency;
import core.thread;
import std.datetime.systime;
import std.uuid;
import std.regex;
import std.exception;

import nngd;
import nngtestutil;

void scb ( void* p ){
    try{
        NNGAio* aio = cast(NNGAio*)p;
        log("Send callback");
        log("Send callback fired pointer: ", p);
        int res = aio.result;
        size_t cnt = aio.count;
        log("Send callback fired with result: ", res, " : ", cnt );
        enforce(res == 0);
    } catch(Throwable e) {
        error(dump_exception_recursive(e, "Send callback"));
    }    
}

void rcb ( void* p ){
    try{
        NNGAio* aio = cast(NNGAio*)p;
        log("Receive callback");
        log("Receive callback fired pointer: ", p);
        int res = aio.result;
        size_t cnt = aio.count;
        log("Receive callback fired with result: ", res, " : ", cnt );
        enforce(res == 0);
        NNGMessage msg  = NNGMessage(0);
        if(aio.get_msg(msg) != nng_errno.NNG_OK){
            error("Received empy msg");
            return;
        }

        log("Received message: ", msg.length, " : ", msg.header_length);
        //enforce( msg.length == 0 || ( msg.length == 27 && msg.header_length == 0 ) );

        if(msg.length > 14){
            auto x = msg.body_trim!string(); 
                log("Received string: ",x);
        }else{
            auto y = msg.header_trim!string();
            log("Received header: ",y);
            auto z = msg.body_trim!string();
            log("Received body: ",z);
        }      
    } catch(Throwable e) {
        error(dump_exception_recursive(e, "Receive callback"));
    }    
}


int
main()
{
    int rc;
    string s = "AbAbAgAlAmAgA";

    log("NNGAio test 1: socket level send-receive");

    string url = "tcp://127.0.0.1:13004";
    try{
        NNGSocket sr = NNGSocket(nng_socket_type.NNG_SOCKET_PULL, false);
        sr.recvtimeout = msecs(1000);
        rc = sr.listen(url);
        enforce(rc == 0);
        NNGSocket ss = NNGSocket(nng_socket_type.NNG_SOCKET_PUSH, false);
        ss.sendtimeout = msecs(1000);
        ss.sendbuf = 4096;
        rc = ss.dial(url);
        enforce(rc == 0);
        
        NNGMessage msg2 = NNGMessage(0);
        rc = msg2.body_append!ushort(11);  enforce(rc == 0);
        rc = msg2.body_append!uint(12);    enforce(rc == 0);
        rc = msg2.body_append!ulong(13);   enforce(rc == 0);
        rc = msg2.body_prepend(cast(ubyte[])s); enforce(rc == 0);
        NNGMessage msg3 = NNGMessage(0);
        
        NNGAio saio = NNGAio(null, null);
        NNGAio raio = NNGAio(null, null); 
        saio.realloc( &scb, &saio );
        raio.realloc( &rcb, &raio );

        log("AIO allocated");

        saio.timeout = msecs(1000);
        raio.timeout = msecs(1000);

        saio.set_msg(msg2);

        ss.sendaio(saio);

        log("AIO send started");

        sr.receiveaio(raio);
        
        log("AIO receive started");

        
        saio.wait();
        raio.wait();

        log("AIO wait completed");
        
        nng_sleep(msecs(1000));

        log("Test error message with header");

        msg3.clear();
        log(format("M3: L: %d H: %d ", msg3.length, msg3.header_length));   
        msg3.body_append("ERROR");
        msg3.header_append("ERROR:404");
        log(format("M3: L: %d H: %d ", msg3.length, msg3.header_length));   
        saio.set_msg(msg3);
        ss.sendaio(saio);

        sr.receiveaio(raio);
        
        saio.wait();
        raio.wait();

    } catch(Throwable e) {
        error(dump_exception_recursive(e, "Main"));
    }    
    nng_sleep(msecs(1000));
    log("...passed");        
    log("Bye!");
    
    return populate_state(7, "NNGAio tests");
}



