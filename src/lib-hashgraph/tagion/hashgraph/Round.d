/// HashGraph Round
module tagion.hashgraph.Round;

//import std.stdio;

import std.datetime; // Date, DateTime
import std.algorithm;
import std.exception : assumeWontThrow;
import std.array : array;
import std.conv;
import std.format;
import std.range;
import std.range : enumerate, tee;
import std.range.primitives : isBidirectionalRange, isForwardRange, isInputRange, walkLength;
import std.stdio;
import std.traits : ReturnType, Unqual;
import std.traits;
import std.typecons;
import std.typecons : No;
import tagion.basic.Types : Buffer;
import tagion.basic.basic : EnumText, basename, buf_idup, this_dot;
import tagion.crypto.Types : Pubkey, Fingerprint;
import tagion.crypto.SecureNet : HashNet;
import tagion.hashgraph.Event;
import tagion.hashgraph.HashGraph : HashGraph;
import tagion.hashgraph.HashGraphBasic;
import tagion.monitor.Monitor : EventMonitorCallbacks;
import tagion.hibon.Document : Document;
import tagion.hibon.HiBON : HiBON;
import tagion.hibon.HiBONRecord : HiBONRecord;
import tagion.logger.Logger;
import tagion.utils.BitMask : BitMask;
import tagion.utils.Miscellaneous;
import tagion.utils.StdTime;
import tagion.basic.Debug;

@safe:

uint level(const size_t c) pure nothrow {
    if (c <= 4) {
        return 0;
    }
    if (c <= 6) {
        return 1;
    }
    if (c <= 8) {
        return 2;
    }
    if (c <= 10) {
        return 3;
    }
    return 4;
}

string level_color(const size_t c) pure nothrow {
    import tagion.utils.Term;

    return [GREEN, BLUE, YELLOW, MAGENTA, RED][level(c)];
}

string show(const BitMask target, const BitMask mask, const size_t size) pure nothrow {
    import tagion.utils.Term;

    const diff = target ^ mask;
    return size.iota.map!(n => __format("%s%d%s", diff[n] ? RED : WHITE, target[n], RESET)).join;
}

debug {
    import std.array;
}
/// Handles the round information for the events in the Hashgraph
class Round {
    //    bool erased;
    enum uint total_limit = 3;
    enum int coin_round_limit = 10;
    protected {
        Round _previous;
        Round _next;
        BitMask _valid_witness;
        BitMask _visit_node_mask; /// Mark if a node has been connected in this round
    }
    immutable int number;

    private Event[] _events;
    protected bool _decided;
    private void decide() pure nothrow @nogc
    in (!_decided, "A round should only be decided once")
    do {
        _decided = true;
    }

    final bool decided() const pure nothrow @nogc {
        return _decided;
    }

    final const(BitMask) valid_witness() const pure nothrow @nogc {
        return _valid_witness;
    }

    final Fingerprint pattern(const HashNet net) const pure nothrow {
        import std.algorithm;

        auto result = assumeWontThrow(net.calcHash(_valid_witness[]
            .map!(n => _events[n])
            .filter!(e => e !is null)
            .map!(e => cast(Buffer) e.fingerprint)
            .array
            .sort
            .join));
        //result.sort;
        pragma(msg, "Pattern ", typeof(result));
        //.sort!((a,b) => a < b);
        return result;
    }

    final EpochVote epochVote(const HashNet net, const long epoch_number) const pure nothrow {
        return EpochVote(epoch_number, cast(uint)(_valid_witness.count), pattern(net));
    }

    final bool completed(HashGraph hashgraph) pure nothrow {
        import tagion.utils.Term;

        if (majority) {
            bool ret;
            auto list_majority_rounds =
                this[].retro
                    .until!(r => !r.majority);

            auto future_witness_masks = list_majority_rounds
                .map!(r => BitMask(r.node_size.iota.filter!(n => (r.events[n]!is null))));
            _valid_witness = BitMask(node_size.iota
                    .filter!(n => (_events[n]!is null) && !_events[n].witness.weak));

            const number_of_future_rounds = cast(int) list_majority_rounds.walkLength;
            const _name = __format("%s%12s @%d%s", level_color(number_of_future_rounds), hashgraph.name, level(
                    number_of_future_rounds), RESET);
            scope (exit) {
                if (ret) {
                    __write(
                            "%s Round %04d  witness=%#s | %(%#s %)".replace(
                            "#", node_size.to!string),
                            _name, number,
                            _valid_witness,
                            future_witness_masks
                            .take(10)
                    );
                }
            }
            if (list_majority_rounds.empty) {
                return ret = false;
            }
            if (number_of_future_rounds < 4) {
                return ret = false;
            }
            const _all = _events.filter!(e => e !is null)
                .all!(e => e.witness.decided) ||
                this[].retro.drop(1)
                    .filter!(r => r.events
                            .filter!(e => e !is null)
                            .all!(e => !e.witness.weak))
                    .map!(r => r.number - number)
                    .any!(diff => diff > 1);

            __write("%s Round %04d     Dec   %(%2d %) => %(%d %) ".replace("#", node_size
                    .to!string),
                    _name,
                    number,
                    _events.map!(e => (e is null) ? -1 : e.witness.decided),
                    this[].retro
                    .map!(r => r.events
                        .filter!(e => e !is null)
                        .all!(e => e.witness.decided))
            );
            if (_all) {
                _valid_witness &= BitMask(_events
                        .filter!(e => (e !is null))
                        .filter!(e => isMajority(e.witness.yes_votes, node_size))
                        .filter!(e => !e.witness.weak)
                        .map!(e => e.node_id));
                __write("%s Round %04d     yes   %(%2d %) votes=%d".replace("#", node_size
                        .to!string),
                        _name,
                        number,
                        _events.map!(e => (e is null) ? -1 : cast(int) e.witness.yes_votes),
                        _events
                        .filter!(e => (e !is null))
                        .filter!(e => isMajority(e.witness.yes_votes, node_size))
                        .count
                );
                __write("%s Round %04d     No    %(%2d %) pattern=%(%02x %)".replace("#", node_size
                        .to!string),
                        _name,
                        number,
                        _events.map!(e => (e is null) ? -1 : cast(int) e.witness.no_votes),
                        pattern(hashgraph.hirpc.net)
                );
                return ret = true;
            }
        }
        return false;
    }

    final const(BitMask) witness_mask() const pure nothrow {
        return BitMask(_events.filter!(e => e !is null)
                .map!(e => e.node_id));
    }

    /**
     * Construct a round from the previous round
     * Params:
     *   previous = previous round
     *   node_size = size of events in a round
     */
    private this(Round previous, const size_t node_size) pure nothrow {
        if (previous) {
            number = previous.number + 1;
            previous._next = this;
            _previous = previous;
        }
        else {
            number = 0;
        }
        _events = new Event[node_size];
    }

    /**
     * All the events in the first ooccurrences of this round
     * Returns: all events in a round
     */
    final const(Event[]) events() const pure nothrow @nogc {
        return _events;
    }

    package final inout(Event[]) events() inout pure nothrow @nogc {
        return _events;
    }

    final uint node_size() const pure nothrow @nogc {
        return cast(uint) _events.length;
    }
    /**
     * Adds the even to round
     * Params:
     *   event = the event to be added
     */
    package final void add(Event event) pure nothrow
    in {
        assert(event._witness, "The event id " ~ event.id.to!string ~ " added to the round should be a witness ");
        assert(_events[event.node_id] is null, "Event at node_id " ~ event.node_id.to!string ~ " should only be added once");
    }
    do {
        _events[event.node_id] = event;
        event._round = this;
    }

    /**
     * Remove the event from the round 
     * Params:
     *   event = event to be removed
     */
    @nogc
    package void remove(const(Event) event) nothrow
    in {
        assert(event.isEva || _events[event.node_id] is event,
        "This event does not exist in round at the current node so it can not be remove from this round");
        assert(event.isEva || !empty, "No events exists in this round");
    }
    do {
        if (!event.isEva && _events[event.node_id]) {
            _events[event.node_id] = null;
        }
    }

    /**
     * Scrap all rounds and events from this round and downwards 
     * Params:
     *   hashgraph = the hashgraph owning the events/rounds
     */
    private void scrap(HashGraph hashgraph) @trusted
    in {
        assert(!_previous, "Round can not be scrapped due that a previous round still exists");
    }
    do {
        void scrap_events(Event e) {
            if (e !is null) {
                scrap_events(e._mother);
                e.disconnect(hashgraph);
                e.destroy;
            }
        }

        foreach (node_id, e; _events) {
            scrap_events(e);
        }
        if (_next) {
            _next._previous = null;
            _next = null;
        }
    }
    /**
     * Previous round from this round
     * Returns: previous round
     */
    @nogc
    package final Round previous() pure nothrow {
        return _previous;
    }

    final const pure nothrow @nogc {
        /**
     * Check of the round has no events
     * Returns: true of the round is empty
     */
        bool empty() {
            return !_events.any!((e) => e !is null);
        }

        /**
     * Counts the number of events which has been set in this round
     * Returns: number of events set
     */
        size_t event_count() {
            return _events.count!((e) => e !is null);
        }

        const(Round) previous() {
            return _previous;
        }

        const(Round) next() {
            return _next;
        }

        /**
     * Get the event a the node_id 
     * Params:
     *   node_id = node id number
     * Returns: 
     *   Event at the node_id
     */
        const(Event) event(const size_t node_id) {
            return _events[node_id];
        }

        bool majority() {
            return isMajority(_events
                    .filter!(e => e !is null)
                    .count,
                    _events.length);
        }

        uint voters() {
            return cast(uint)(_events.filter!(e => e !is null).count);
        }
    }

    invariant {
        assert(!_previous || (_previous.number + 1 is number));
        assert(!_next || (_next.number - 1 is number));
    }

    /**
 * Range from this round and down
 * Returns: range of rounds 
 */
    @nogc
    package final Rounder.Range!false opSlice() pure nothrow {
        return Rounder.Range!false(this);
    }

    /// Ditto
    @nogc
    final Rounder.Range!true opSlice() const pure nothrow {
        return Rounder.Range!true(this);
    }

    /**
     * The rounder takes care of cleaning up old round 
     * and keeps track of if an round has been decided or can be decided
     */
    struct Rounder {
        Round last_round;
        Round last_decided_round;
        Round round_to_be_decided;
        HashGraph hashgraph;
        Event[] last_witness_events;

        @disable this();

        this(HashGraph hashgraph) pure nothrow {
            this.hashgraph = hashgraph;
            last_round = new Round(null, hashgraph.node_size);
            last_witness_events.length = hashgraph.node_size;
        }

        package void erase() {
            void local_erase(Round r) @trusted {
                if (r !is null) {
                    local_erase(r._previous);
                    r.scrap(hashgraph);
                    r.destroy;
                }
            }

            Event.scrapping = true;
            scope (exit) {
                Event.scrapping = false;
            }
            last_decided_round = null;
            local_erase(last_round);
        }

        /**
     * Sets the round for an event and creates an new round if needed
     * Params:
     *   e = event
     */
        void set_round(Event e) nothrow
        in {
            assert(!e._round, "Round has already been added");
            assert(last_round, "Base round must be created");
            assert(last_decided_round, "Last decided round must exist");
            assert(e, "Event must create before a round can be added");
        }
        do {
            scope (exit) {
                if (e._witness) {
                    e._round.add(e);
                    last_witness_events[e.node_id] = e;
                }
                if (e._father && e._father._round.number == e._round.number) {
                    e._round._visit_node_mask[e._father.node_id] = true;
                }
            }
            e._round = e.maxRound;
            if (e._witness && e._round._events[e.node_id]) {
                if (e._round._next) {
                    e._round = e._round._next;
                    return;
                }
                e._round = new Round(last_round, hashgraph.node_size);
                last_round = e._round;
            }
        }

        //Cleans up old round and events if they are no-longer needed

        package
        void dustman() {
            void local_dustman(Round r) {
                if (r !is null) {
                    local_dustman(r._previous);
                    r.scrap(hashgraph);
                }
            }

            Event.scrapping = true;
            scope (exit) {
                Event.scrapping = false;
            }
            if (hashgraph.scrap_depth != 0) {
                int depth = hashgraph.scrap_depth;
                for (Round r = last_decided_round; r !is null; r = r._previous) {
                    depth--;
                    if (depth < 0) {
                        local_dustman(r);
                        break;
                    }
                }
            }
        }

        @nogc final const pure nothrow {
            /**
  * Number of round epoch in the rounder queue
  * Returns: size of the queue
   */
            size_t length() {
                return this[].walkLength;
            }

            bool isEventInLastDecidedRound(const(Event) event) {
                if (!last_decided_round) {
                    return false;
                }

                return last_decided_round.events
                    .filter!((e) => e !is null)
                    .map!(e => e.event_package.fingerprint)
                    .canFind(event.event_package.fingerprint);
            }

            /**
     * Calculates the number of rounds since the last decided round
     * Returns: number of undecided roundes 
     */
            long coin_round_distance() {
                return last_round.number - last_decided_round.number;
            }

            /**
     * Number of decided round in cached in memory
     * Returns: Number of cached decided rounds
     */

            uint cached_decided_count() {
                uint _cached_decided_count(const Round r, const uint i = 0) pure nothrow {
                    if (r) {
                        return _cached_decided_count(r._previous, i + 1);
                    }
                    return i;
                }

                return _cached_decided_count(last_round);
            }

            /**
     * Check the coin round limit
     * Returns: true if the coin round has been exceeded 
     */
            bool check_decided_round_limit() {
                return cached_decided_count > total_limit;
            }

            uint count_majority_rounds(const Round r) {
                return cast(uint) r[].retro
                    .until!(r => !r.majority)
                    .count;
            }
        }
        enum rounds_beyond_limit = 3;
        void check_decide_round() {
            import tagion.utils.Term;

            auto _round_to_be_decided = last_decided_round._next;
            if (!_round_to_be_decided) {
                return;
            }
            auto witness_in_round = _round_to_be_decided._events
                .filter!(e => e !is null)
                .map!(e => e.witness);
            const _name = hashgraph.name;
            const new_completed = _round_to_be_decided.completed(hashgraph);

            if (!new_completed) {
                return;
            }
            __write(
                    "%s %s%sRound %04d%s can be decided  witness=%d",
                    _name,
                    BOLD, GREEN,
                    _round_to_be_decided.number,
                    RESET,
                    witness_in_round.walkLength
            );
            Event.view(witness_in_round.map!(w => w.outer));
            round_to_be_decided = _round_to_be_decided;
            return;
            string show(const Event e) {
                if (e) {
                    return format("%s%d%s", (round_to_be_decided._valid_witness[e.node_id]) ? GREEN : YELLOW, e
                        .order, RESET);
                }
                return format("%sX %s", RED, RESET);
            }

            log("Round %04d decided", round_to_be_decided.number);
            last_decided_round = round_to_be_decided;
            round_to_be_decided.decide;
            hashgraph.statistics.future_majority_rounds(count_majority_rounds(round_to_be_decided));
            log.event(Event.topic, hashgraph.statistics.future_majority_rounds.stringof,
                    hashgraph.statistics.future_majority_rounds);

            if (!isMajority(round_to_be_decided._valid_witness.count,
                    hashgraph.node_size)) {
                __write("%12s %sRound %04d%s Not collected", hashgraph.name, RED, round_to_be_decided.number, RESET);

                __write("%s %sRound %04d%s epoch %-(%s %) collected=0  votes=%#s yes=%d  "
                        .replace("#", round_to_be_decided.node_size.to!string),
                        _name,
                        RED,
                        round_to_be_decided.number,
                        RESET,
                        round_to_be_decided._events.map!(e => show(e)),
                        round_to_be_decided._valid_witness,
                        round_to_be_decided._valid_witness.count,
                );
                return;
            }
            collect_received_round(round_to_be_decided);
        }

        void check_received_round() {
            import tagion.utils.Term;
            if (round_to_be_decided) {
            const _name = hashgraph.name;
                scope (exit) {
                    round_to_be_decided = null;
                }
                string show(const Event e) {
                    if (e) {
                        return format("%s%d%s", (round_to_be_decided._valid_witness[e.node_id]) ? GREEN : YELLOW, e
                            .order, RESET);
                    }
                    return format("%sX %s", RED, RESET);
                }

                log("Round %04d decided", round_to_be_decided.number);
                last_decided_round = round_to_be_decided;
                round_to_be_decided.decide;
                hashgraph.statistics.future_majority_rounds(count_majority_rounds(round_to_be_decided));
                log.event(Event.topic, hashgraph.statistics.future_majority_rounds.stringof,
                        hashgraph.statistics.future_majority_rounds);

                if (!isMajority(round_to_be_decided._valid_witness.count,
                        hashgraph.node_size)) {
                    __write("%12s %sRound %04d%s Not collected", hashgraph.name, RED, round_to_be_decided.number, RESET);

                    __write("%s %sRound %04d%s epoch %-(%s %) collected=0  votes=%#s yes=%d  "
                            .replace("#", round_to_be_decided.node_size.to!string),
                            _name,
                            RED,
                            round_to_be_decided.number,
                            RESET,
                            round_to_be_decided._events.map!(e => show(e)),
                            round_to_be_decided._valid_witness,
                            round_to_be_decided._valid_witness.count,
                    );
                    return;
                }
                collect_received_round(round_to_be_decided);
            }

        }

        protected void collect_received_round(Round r)
        in (r.decided, "The round should be decided before the round can be collected")
        do {
            import tagion.utils.Term;

            auto witness_event_in_round = r._events.filter!(e => e !is null);
            const _name = format("%s%12s%s",
                    level_color(r[].retro.drop(1)
                .until!(r => !r.majority).count), hashgraph.name, RESET);
            Event[] majority_seen_from_famous(R)(R famous_witness_in_round) @safe if (isInputRange!R) {
                Event[] event_list;
                event_list.length = hashgraph.node_size * hashgraph.node_size;
                uint index;
                foreach (famous_witness; famous_witness_in_round) {
                    BitMask father_mask;
                    foreach (e; famous_witness[].until!(e => !e || e.round_received)) {
                        if (e._father && !father_mask[e._father.node_id]) {
                            father_mask[e._father.node_id] = true;
                            event_list[index++] = e;
                        }
                    }
                }
                event_list.length = index;
                return event_list;
            }

            auto famous_witness_in_round = witness_event_in_round
                .filter!(e => r._valid_witness[e.node_id]);
            auto event_list = majority_seen_from_famous(famous_witness_in_round);
            event_list
                .sort!((a, b) => Event.higher_order(a, b));
            BitMask[] famous_seen_masks;
            famous_seen_masks.length = hashgraph.node_size;

            Event[] event_front;
            event_front.length = hashgraph.node_size;
            foreach (e; event_list) {
                famous_seen_masks[e.node_id][e.node_id] = true;
                famous_seen_masks[e._father.node_id] |= famous_seen_masks[e.node_id];
                if (!event_front[e._father.node_id] && isMajority(famous_seen_masks[e._father.node_id], hashgraph)) {
                    event_front[e._father.node_id] = e._father;
                }
            }
            bool done;
            do {
                done = true;
                foreach (e; event_front.filter!(e => e !is null)) {
                    foreach (e_father; e[]
                        .until!(e => !e || e.round_received)
                        .filter!(e => e._father)
                        .map!(e => e._father)
                        .filter!(e_father => !event_front[e_father.node_id] ||
                        e_father.order > event_front[e_father.node_id].order)
                    ) {
                        done = false;
                        event_front[e_father.node_id] = e_father;
                    }
                }
            }
            while (!done);

            event_front
                .filter!(e => e !is null)
                .each!(e => e.collector = true);

            auto event_collection = event_front
                .filter!(e => e !is null)
                .map!(e => e[]
                .until!(e => e.round_received !is null))
                .joiner
                .array;
            event_collection.each!(e => e.round_received = r);
            Event.view(event_collection);
            hashgraph.statistics.epoch_events(event_collection.length);
            log.event(Event.topic, hashgraph.statistics.epoch_events.stringof, hashgraph
                    .statistics.epoch_events);
            string show(const Event e) {
                if (e) {
                    return format("%s%d%s", (r._valid_witness[e.node_id]) ? GREEN : YELLOW, e.order, RESET);
                }
                return format("%sX %s", RED, RESET);
            }

            __write("%12s %sRound %04d%s epoch %-(%s %) collected=%d  votes=%#s yes=%d"
                    .replace("#", r.node_size.to!string),

                    _name,
                    GREEN,
                    r.number,
                    RESET,
                    r._events.map!(e => show(e)),
                    event_collection.length,
                    r._valid_witness,
                    r._valid_witness.count,
            );
            hashgraph.epoch(event_collection, r);

        }

        /**
     * Call to collect and order the epoch
     * Params:
     *   r = decided round to collect events to produce the epoch
     *   hashgraph = hashgraph which owns this round
     */

        /**
         * Range from this round and down
         * Returns: range of rounds 
         */
        @nogc
        package Range!false opSlice() pure nothrow {
            return Range!false(last_round);
        }

        /// Ditto
        @nogc
        Range!true opSlice() const pure nothrow {
            return Range!true(last_round);
        }

        /**
     * Range of rounds 
     */
        @nogc
        struct Range(bool CONST = true) {
            private Round round;
            this(const Round round) pure nothrow @trusted {
                this.round = cast(Round) round;
            }

            pure nothrow {
                static if (CONST) {
                    const(Round) front() const {
                        return round;
                    }
                }
                else {
                    Round front() {
                        return round;
                    }
                }

                alias back = front;

                bool empty() const {
                    return round is null;
                }

                void popBack() {
                    round = round._next;
                }

                void popFront() {
                    round = round._previous;
                }

                Range save() {
                    return Range(round);
                }

            }

        }

        static assert(isInputRange!(Range!true));
        static assert(isForwardRange!(Range!true));
        static assert(isBidirectionalRange!(Range!true));
    }

}
