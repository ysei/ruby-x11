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

require 'X11/Xlib/events'

module X11

class Event
	module Mode
		AsyncPointer   = 0
		SyncPointer    = 1
		ReplayPointer  = 2
		AsyncKeyboard  = 3
		SyncKeyboard   = 4
		ReplayKeyboard = 5
		AsyncBoth      = 6
		SyncBoth       = 7

		def self.[] (name)
			const_get name
		end
	end

	def self.index (name)
		Events.each_with_index {|event, index|
			next if event.nil?

			return index if event.name[/[^:]*$/] == name.to_s
		}
	end

	def self.new (event)
		event = event.typecast(C::XEvent) unless event.is_a?(C::XEvent)

		(Events[event[:type]] || Any).new(event)
	end

	def self.mask_for (what)
		case what
			when Array
				what.inject(Mask::Event[]) {|a, b| mask_for(a) + mask_for(b) }

			when Symbol
				Mask::Event[*(Events.find {|event|
					event && event.name[/[^:]*$/].to_sym == what
				}.mask rescue [])]

			when Bitmap::Value
				what

			when Regexp
				Mask::Event[*Events.select {|event|
					event && event.name[/[^:]*$/].match(what)
				}.map {|event|
					event.mask
				}.flatten.compact.uniq]

			when nil
				Mask::Event.all
		end
	end
end

class C::XEvent
	Events.to_a.compact.each {|type|
		next unless type.attribute rescue nil

		define_method(type.attribute) {
			type.new(self)
		}
	}
end

end
