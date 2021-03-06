#--
# Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY meh ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL meh OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied.
#++

require 'X11/Xlib/graphic_context/functions'
require 'X11/Xlib/graphic_context/values'

module X11

class GraphicContext
	def self.create (display, drawable, values=nil)
		raise ArgumentError, 'the passed value is not drawable' unless drawable.is_a?(Drawable)

		GraphicContext.new(display, C::XCreateGC(display.to_native, drawable.to_native, *Values.new(self, values).to_native))
	end

	attr_reader :display

	def initialize (display, value)
		@display = display
		@value   = value
	end

	def copy (mask=nil)
		GraphicContext.new(display, drawable).tap {|gc|
			C::XCopyGC(display.to_native, to_native, gc.to_native, mask ? mask.to_native : result.values.to_native.first)

			gc.values.mask = mask || gc.values.mask
		}
	end

	def id
		C::XGContextFromGC(to_native)
	end

	def flush
		C::XFlushGC(display.to_native, to_native)
	end

	def to_native
		@value
	end
end

end
