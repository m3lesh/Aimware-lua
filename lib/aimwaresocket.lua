local ffi = require("ffi")

ffi.cdef[[
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
    int bind(int sockfd, const struct sockaddr *addr, int addrlen);
    int listen(int sockfd, int backlog);
    int accept(int sockfd, struct sockaddr *addr, int *addrlen);
    ssize_t send(int sockfd, const void *buf, size_t len, int flags);
    ssize_t recv(int sockfd, void *buf, size_t len, int flags);
    int close(int fd);
    uint16_t htons(uint16_t hostshort);
    in_addr_t inet_addr(const char *cp);
    char *inet_ntoa(struct in_addr in);
    uint16_t ntohs(uint16_t netshort);
]]

local socket = {}

-- Create a TCP socket
function socket.create()
    local sockfd = ffi.C.socket(2, 1, 0)  -- AF_INET = 2, SOCK_STREAM = 1, IPPROTO_TCP = 0
    if sockfd < 0 then
        error("Failed to create socket.")
    end
    return sockfd
end

-- Bind the socket to a specific port and address
function socket.bind(sockfd, port)
    local addr = ffi.new("struct sockaddr_in")
    addr.sin_family = 2  -- AF_INET
    addr.sin_port = ffi.C.htons(port)
    addr.sin_addr.s_addr = ffi.C.inet_addr("0.0.0.0")  -- Bind to any local IP

    local result = ffi.C.bind(sockfd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
    if result < 0 then
        error("Failed to bind socket.")
    end
end

-- Listen for incoming connections
function socket.listen(sockfd)
    local result = ffi.C.listen(sockfd, 5)  -- backlog of 5
    if result < 0 then
        error("Failed to listen on socket.")
    end
end

-- Accept an incoming client connection and return the client's info (IP and port)
function socket.accept(sockfd)
    local client_addr = ffi.new("struct sockaddr_in")
    local addr_len = ffi.new("int[1]", ffi.sizeof(client_addr))

    local client_fd = ffi.C.accept(sockfd, ffi.cast("struct sockaddr *", client_addr), addr_len)
    if client_fd < 0 then
        error("Failed to accept client connection.")
    end

    -- Get the client's IP and port
    local client_ip = ffi.string(ffi.C.inet_ntoa(client_addr.sin_addr))
    local client_port = ffi.C.ntohs(client_addr.sin_port)

    return client_fd, client_ip, client_port
end

-- Send data to the client
function socket.send(sockfd, data)
    local result = ffi.C.send(sockfd, data, #data, 0)
    if result < 0 then
        error("Failed to send data.")
    end
end

-- Receive data from the client
function socket.receive(sockfd, length)
    local buffer = ffi.new("char[?]", length)
    local result = ffi.C.recv(sockfd, buffer, length, 0)
    if result < 0 then
        error("Failed to receive data.")
    end
    return ffi.string(buffer, result)
end

-- Close the socket
function socket.close(sockfd)
    ffi.C.close(sockfd)
end

return socket
