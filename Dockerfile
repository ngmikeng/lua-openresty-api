FROM openresty/openresty

# --- Begin ---
# For debugging lua code: https://dev.to/omervk/debugging-lua-inside-openresty-inside-docker-with-intellij-idea-2h95
RUN apt-get update; apt-get install -y curl
RUN apt-get -y install build-essential

RUN curl https://cmake.org/files/v3.7/cmake-3.7.2.tar.gz \
         -o cmake-3.7.2.tar.gz && \
    tar -xvzf cmake-3.7.2.tar.gz && \
    cd cmake-3.7.2 && \
        ./configure && \
        make && \
        make install && \
    cd .. && \
    rm -rf cmake-3.7.2 cmake-3.7.2.tar.gz && \
    update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
RUN curl https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/1.0.16.tar.gz \
         -L -o EmmyLuaDebugger-1.0.16.tar.gz && \
    tar -xzvf EmmyLuaDebugger-1.0.16.tar.gz && \
    cd EmmyLuaDebugger-1.0.16 && \
        mkdir -p build && \
        cd build && \
            cmake -DCMAKE_BUILD_TYPE=Release ../ && \
            make install && \
            mkdir -p /usr/local/emmy && \
            cp install/bin/emmy_core.so /usr/local/emmy/ && \
        cd .. && \
    cd .. && \
    rm -rf EmmyLuaDebugger-1.0.16 EmmyLuaDebugger-1.0.16.tar.gz
# --- End ---

RUN chmod -R 777 /usr/local/openresty/nginx/html/