# The MIT License (MIT)
# 
# Copyright (c) 2016 Vlad Balmos
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "socket"
require "json"
require "thread"

class Control

    def initialize(socket_path)
        @socket_path = socket_path
        @server = nil
    end

    def listen_for_commands
        Thread.new do
            @server = UNIXServer.new(@socket_path)

            loop do
                client = @server.accept
                command, _unused = client.recvfrom 1024
                command.strip!
                response = execute_command command
                response && client.puts(response)
                client.close
            end
        end
    end

    def execute_command(command)
        if command == "get_pid"
            return Process.pid
        end
        puts command
    end

    def stop_listening
        puts "Right here - right now"
        @server.close
        File.unlink @socket_path
    end

    def stop
        # Get the pid
        socket = UNIXSocket.new(@socket_path)
        socket.puts "get_pid"
        process_pid = socket.gets
        socket.close

        # Send the kill signal
        Process.kill "TERM", process_pid.to_i
    end
end
