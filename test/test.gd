extends SceneTree

func ASSERT(condition, message='Assertion failed.'):
    if not condition:
        push_error(message)
        quit()

func _init():
    print('Starting test')

    var foreigner = load('res://foreigner.gdns').new()
    ASSERT(foreigner)
    prints('Foreigner:', foreigner)

    var lib = foreigner.open('./testlib.so')
    ASSERT(lib)
    print('Library:', lib)

    var result

    print('##### General tests')

    print('* Testing int getNumber(void)')
    lib.define('getNumber', 'sint32', [])
    result = lib.invoke('getNumber')
    print(result)
    ASSERT(result == 42)

    print('* Testing int sqr(int)')
    lib.define('sqr', 'sint32', ['sint32'])
    result = lib.invoke('sqr', [9])
    print(result)
    ASSERT(result == 81)
    lib.define('sqr', 'sint32', ['sint32'])
    result = lib.invoke('sqr', [16])
    print(result)
    ASSERT(result == 256)

    print('* Testing int add2i(int, int)')
    lib.define('add2i', 'sint32', ['sint32', 'sint32'])
    result = lib.invoke('add2i', [6, 8])
    print(result)
    ASSERT(result == 14)

    print('* Testing double add3d(double, double)')
    lib.define('add3d', 'double', ['double', 'double', 'double'])
    result = lib.invoke('add3d', [3.0, 4.0, 5.0])
    print(result)
    ASSERT(result == 12.0)

    print('##### Pointers')

    print('* Testing int retrieveInt(allocateInt(int))')
    lib.define('allocateInt', 'pointer', ['sint32'])
    lib.define('retrieveInt', 'sint32', ['pointer'])
    result = lib.invoke('retrieveInt', [lib.invoke('allocateInt', [1337])])
    print(result)
    ASSERT(result == 1337)

    print('##### Strings')

    print('* Testing const char* getConstString()')
    lib.define('getMessage', 'string', [])
    result = lib.invoke('getMessage', [])
    print(result)
    ASSERT(result == 'Hello world!')

    print('* Testing char* joinStrings(char*, char*)')
    lib.define('joinStrings', 'string', ['string', 'string'])
    result = lib.invoke('joinStrings', ['Foo', 'bar'])
    print(result)
    ASSERT(result == 'Foobar')

    print('Testing finished')
    quit()

