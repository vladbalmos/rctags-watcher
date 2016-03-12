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

require_relative "logger_helper"
require "logger"
require "socket"
require "json"
require "thread"

class Control

    include LoggerHelper

    def initialize(socket_path)
        @socket_path = socket_path
        @server = nil
        @server_thread = nil
    end

    def listen_for_commands
        log Logger::DEBUG, "Starting the remote control thread"
        @server_thread = Thread.new do
            @server = UNIXServer.new(@socket_path)

            log Logger::INFO, "Created UNIXServer at #{@socket_path}"
            loop do
                begin
                    client = @server.accept
                rescue SystemCallError => e
                    log Logger::ERROR, "Caught exception while waiting for clients: #{e.message}"
                    break
                end

                handle_client client
            end
            log Logger::DEBUG, "Exited event loop"
        end
    end

    def handle_client(client)
        log Logger::DEBUG, "New client connected"

        begin
            command, _unused = client.recvfrom 1024
        rescue SystemCallError => e
            log Logger::ERROR, "Error receiving data from client: #{e.message}, #{e.backtrace}"
            return
        end

        command.strip!

        log Logger::INFO, "Executing command #{command}"
        response = execute_command command
        if response
            log Logger::DEBUG, "Sending response to client: #{response}"

            begin
                client.puts response
            rescue SystemCallError => e
                log Logger::ERROR, "Error writing data to client: #{e.message}, #{e.backtrace}"
                return
            end
        end

        begin
            client.close
        rescue
        end
        log Logger::DEBUG, "Disconnected client"
    end

    def execute_command(command)
        if command == "get_pid"
            return Process.pid
        end
        puts command
    end

    def stop_listening
        log Logger::DEBUG, "Stopping UNIXServer ..."

        @server.shutdown
        @server.close
        @server_thread.join 1

        File.unlink @socket_path
        log Logger::INFO, "UNIXServer stopped"
    end

    def stop
        # Get the pid
        begin
            socket = UNIXSocket.new(@socket_path)
        rescue SystemCallError => e
            abort "Unable to connect to socket. Error: #{e.message}"
            return
        end

        socket.puts "get_pid"
        process_pid = socket.gets
        socket.close

        # Send the kill signal
        Process.kill "TERM", process_pid.to_i
    end
end
