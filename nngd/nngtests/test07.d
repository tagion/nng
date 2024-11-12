module nngd.nngtests.test07;

import std.stdio;
import std.concurrency;
import std.exception;
import std.json;
import std.format;
import std.conv;
import std.datetime.systime;
import std.uuid;
import core.thread;
import core.thread.osthread;
import nngd;

const _testclass = "nngd.nngtests.nng_test07_aio_callback";


alias delegate_fun = void delegate(void*);


@trusted class nng_test07_aio_callback : NNGTest {
    
    this(Args...)(auto ref Args args) { 
        super(args);
    }    

    
    NNGAio* saio;
    NNGAio* raio; 

    override string[] run(){
        log("NNG test 07: aio callbback");
        int rc;
        string s = "AbAbAgAlAmAgA";
        string url = "tcp://127.0.0.1:13007";
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
            
            saio = new NNGAio(null, null);
            raio = new NNGAio(null, null);
            
            auto f1 = bindit(&this.scb);
            auto f2 = bindit(&this.rcb);
            writeln("XX: ",saio,"  ",raio," ",f1," ",f2);
            saio.realloc( f1, cast(void*)saio );
            raio.realloc( f2, cast(void*)raio );

            log("AIO allocated");

            saio.timeout = msecs(1000);
            raio.timeout = msecs(1000);
            log("d1");
            saio.set_msg(msg2);
            log("d2");

            ss.sendaio(*saio);
            log("d3");

            log("AIO send started");

            sr.receiveaio(*raio);
            
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
            ss.sendaio(*saio);

            sr.receiveaio(*raio);
            
            saio.wait();
            raio.wait();

            Thread.sleep(msecs(500));
        } catch(Throwable e) {
            error(dump_exception_recursive(e, "Main: " ~ _testclass));
        }    
        log(_testclass ~ ": Bye!");      
        return [];
    }
    
    private:

    void scb ( void* p ) {
        writeln("scb in ", p);
        try{
            this.log("Send callback");
            writeln("scb 1 ", p);
            if(p is null){ error("Null send AIO"); return; } 
            writeln("scb 2");
            NNGAio* aio = cast(NNGAio*)p;
            writeln("scb 3 ", aio);
            this.log("Send callback fired pointer: ", p);
            writeln("scb 4");
            aio.wait;
            writeln("scb 4`");
            int res = aio.result;
            writeln("scb 5");
            size_t cnt = aio.count;
            writeln("scb 6");
            this.log("Send callback fired with result: ", res, " : ", cnt );
            writeln("scb 7");
            enforce(res == 0);
        } catch(Throwable e) {
            this.error(dump_exception_recursive(e, "Send callback"));
        }    
    }

    void rcb ( void* p ) {
        try{
            log("Receive callback");
            if(p is null){ error("Null recv AIO"); return; } 
            NNGAio* aio = cast(NNGAio*)p;
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

    nng_aio_cb bindit ( delegate_fun f ){
        return f.funcptr;
    }
    
}


