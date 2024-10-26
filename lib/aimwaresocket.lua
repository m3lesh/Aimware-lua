ffi.cdef [[
    typedef int SOCKET;
    typedef uint32_t in_addr_t;
    typedef unsigned short sa_family_t;

    struct in_addr {
        in_addr_t s_addr;
    };

    struct sockaddr {
        sa_family_t sa_family;
        char sa_data[14];
    };

    struct sockaddr_in {
        sa_family_t sin_family;
        uint16_t sin_port;
        struct in_addr sin_addr;
        char sin_zero[8];
    };

    int socket(int domain, int type, int protocol);
    int connect(int sockfd, const struct sockaddr *addr, int addrlen);
    ssize_t send(int sockfd, const void *buf, size_t len, int flags);
    ssize_t recv(int sockfd, void *buf, size_t len, int flags);
    int close(int fd);
    uint16_t htons(uint16_t hostshort);
    in_addr_t inet_addr(const char *cp);
]]

-- Define your socket library as a table
local socket = {}

-- Create a TCP socket
function socket.create()
    local sockfd = ffi.C.socket(2, 1, 0) -- AF_INET = 2, SOCK_STREAM = 1, IPPROTO_TCP = 0
    if sockfd < 0 then
        print("Failed to create socket.")
    end
    return sockfd
end

-- Connect to a server
function socket.connect(sockfd, address, port)
    local addr = ffi.new("struct sockaddr_in")
    addr.sin_family = 2 -- AF_INET
    addr.sin_port = ffi.C.htons(port)
    addr.sin_addr.s_addr = ffi.C.inet_addr(address)

    local result = ffi.C.connect(sockfd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
    if result < 0 then
        print("Failed to connect to server.")
    end
end

-- Send data
function socket.send(sockfd, data)
    local result = ffi.C.send(sockfd, data, #data, 0)
    if result < 0 then
        print("Failed to send data.")
    end
end

-- Receive data
function socket.receive(sockfd, length)
    local buffer = ffi.new("char[?]", length)
    local result = ffi.C.recv(sockfd, buffer, length, 0)
    if result < 0 then
        print("Failed to receive data.")
    end
    return ffi.string(buffer, result)
end

-- Close the socket
function socket.close(sockfd)
    ffi.C.close(sockfd)
end

-- Return the socket table/module
return socket
