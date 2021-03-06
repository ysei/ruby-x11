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

module X11

class Image
	def self.finalizer (image)
		proc {
			C::XDestroyImage(image)
		}
	end

	singleton_named :drawable, :x, :y, :width, :height, :plane, :format, :optional => 1 .. -1, :alias => { :w => :width, :h => :height }
	def self.from (drawable, x=nil, y=nil, width=nil, height=nil, plane_mask=nil, format=nil)
		display      = drawable.display
		x          ||= 0
		y          ||= 0
		width      ||= drawable.width
		height     ||= drawable.height
		plane_mask ||= Planes.all
		format     ||= Pixmap::Format::Z

		Image.new(C::XGetImage(drawable.display.to_native, drawable.to_native, x, y, width, height, plane_mask, format))
	end

	def initialize (pointer)
		raise ArgumentError, 'you have to pass a pointer to the XImage struct' unless pointer.is_a?(FFI::Pointer)

		@value = pointer

		ObjectSpace.define_finalizer self, self.class.finalizer(display, to_native)
	end

	def to_native
		@value
	end
end

end
