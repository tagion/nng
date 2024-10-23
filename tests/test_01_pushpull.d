import std.stdio;
import std.conv;
import std.string;
import std.concurrency;
import core.thread;
import std.datetime.systime;
import std.exception;

import nngd;
import nngtestutil;

const NSTEPS = 9;
const NDIALS = 10;

void sender_worker(string url)
{
    log("============ Sender worker");
    try {
        int k = 0;
        string line;
        int rc;
        thread_attachThis();
        rt_moduleTlsCtor();
        NNGSocket s = NNGSocket(nng_socket_type.NNG_SOCKET_PUSH);
        s.sendtimeout = msecs(1000);
        s.sendbuf = 4096;
        while(1){
            log("SS: to dial...");
            rc = s.dial(url);
            if(rc == 0) break;
            if(rc == nng_errno.NNG_ECONNREFUSED && k++ < NDIALS){
                log("SS: Connection refused attempt %d", k);
                nng_sleep(msecs(100));
                continue;
            }
            error("SS: Dial error after %d attempts: %s", NDIALS, rc);
            enforce(rc == 0);
        }
        if(s.state is nng_socket_state.NNG_STATE_CONNECTED){
            log(">> connected with : " ~ nng_errstr(s.errno));
        }
        log(nngtest_socket_properties(s,"sender"));
        k = 0;
        while(1){
            line = format(">MSG:%d DBL:%d TRL:%d<",k,k*2,k*3);
            if(k > NSTEPS) line = "END";
            auto buf = cast(ubyte[])line.dup;
            rc = s.send!(ubyte[])(buf);
            enforce(rc == 0);
            log("SS sent: ",k," : ",line);
            k++;
            nng_sleep(msecs(500));
            if(k > NSTEPS + 1) break;
        }
        log(" SS: bye!");
    } catch(Throwable e) {
        error(dump_exception_recursive(e, "Sender worker"));
    }    
}


void receiver_worker(string url)
{
    log("============ Receiver worker");
    try {
        int rc;
        ubyte[4096] buf;
        size_t sz = buf.length;
        thread_attachThis();
        rt_moduleTlsCtor();
        NNGSocket s = NNGSocket(nng_socket_type.NNG_SOCKET_PULL);
        s.recvtimeout = msecs(1000);
        rc = s.listen(url);
        log("RR: listening");
        enforce(rc == 0);
        bool _ok = false;
        int k = 0;
        log(nngtest_socket_properties(s,"receiver"));
        while(1){
            if(k++ > NSTEPS + 3) break;
            sz = s.receivebuf(buf, buf.length);
            if(sz < 0 || sz == size_t.max){
                error("REcv error: " ~ nng_errstr(s.errno));
                continue;
            }
            auto str = cast(string)buf[0..sz];
            log("RR: GOT["~(to!string(sz))~"]: >"~str~"<");
            if(str == "END"){
                _ok = true;
                break;
            }    
        }
        if(!_ok){
            error("Test stopped without normal end.");
        }
        log(" RR: bye!");
    } catch(Throwable e) {
        error(dump_exception_recursive(e, "Receiver worker"));
    }    
}


int main()
{
    log("Hello NNGD!");
    log("Simple push-pull test with byte buffers");

    string uri = "tcp://127.0.0.1:31200";

    auto tid01 = spawn(&receiver_worker, uri);
    auto tid02 = spawn(&sender_worker, uri);
    thread_joinAll();

    return populate_state(1, "simple push-pull socket pair");
}

