import vibe.vibe;

@safe:

URLRouter router;

@trusted void run()
{
    runApplication();
}

void main()
{
    router = new URLRouter;
    router.registerWebInterface(new WebInterface);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, &setupAllocator);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	run();
}

void foo(int* a)
{

}

class WebInterface
{
    void index()
    {
        auto b = allocator.allocate();
        foo(b.buffer);
        logInfo("index");
    }
}

@trusted struct FiberLocal
{
    TaskLocal!Allocator local;

    @trusted auto storage()
    {
        return local.storage;
    }

    @trusted auto allocate()
    {
        return local.allocate;
    }

    @trusted void setup()
    {
        local.setup;
    }

    @trusted void teardown()
    {
        local.teardown;
    }
}

int* globalBuffer;
int* global;
FiberLocal allocator;

struct Allocator
{
    void setup()
    {
        logInfo("setup allocator");
    }

    void teardown()
    {
        logInfo("teardown allocator");
    }

    Buffer allocate()
    {
        logInfo("allocate");
        return Buffer(globalBuffer);
    }
}

struct Buffer
{
    private int* buffer_;

    int* buffer() return
    {
        return buffer_;
    }
}

void setupAllocator(HTTPServerRequest req, HTTPServerResponse res)
{
    allocator.setup();
    scope (exit) allocator.teardown();
    router.handleRequest(req, res);
}
