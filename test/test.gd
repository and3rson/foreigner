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

    var lib = foreigner.open('testlib.so')
    ASSERT(lib)
    print('Library:', lib)

    var result

    print('* Testing int getNumber(void)')
    lib.define('getNumber', 'sint32', [])
    result = lib.invoke('getNumber')
    print(result)
    ASSERT(result == 42)

    print('* Testing int sqr(int)')
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

    print('Testing finished')
    quit()

