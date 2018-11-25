Struct.new("Note", :value, :duration, :amplitude, :slide)

def notes(note_s)
  counter = 0
  polyvals=[]
  vals = []
  last_note = ''
  last_dur = 1
  counter = 0
  poly=0
  polyvals[poly]=vals
  oct = 3
  amplitude = 1.0
  note_s.split(' ').each do |note|
    note.strip!
    note.downcase!
    case note
    when '-'
      lookback_counter = 0
      while (!vals[lookback_counter] && (vals[lookback_counter].value>0))
        lookback_counter -=1
      end
      if lookback_counter>=0
        vals[lookback_counter].duration+=1
      end
      vals[counter]=Struct::Note::new(-1, 1, amplitude, 0)
      counter += 1
    when '*'
      vals[counter]=Struct::Note::new(-1, 1, amplitude, 0)
      counter += 1
    when '/'
      counter=0
      poly += 1
      vals = []
      polyvals[poly]=vals
    when '>'
      oct += 1
    when '<'
      oct -=1
      if oct < 0
        oct = 0
      end
    when /^[\d | \.]+?$/
        vals[counter]=Struct::Note::new(note.to_f+(oct*12), 1, amplitude, 0)
        counter += 1
    when /^a[\d | \.]+?$/
      amplitude = note.slice(1,note.size()-1).to_f
    else
      puts "? " + note
    end
  end
  return polyvals
end


def play_notes(note_s, step_size=1, shift=0)
  the_notes = notes(note_s)
  puts the_notes.to_s
  polycursor=0
  polys = the_notes.size()
  ended = false
  counter = 0
  while !ended
    ended = true
    the_notes.each do |line|
      if polycursor < line.size()
        note = line[polycursor]
        if (note.value>0)
          play note.value+shift, release:note.duration*step_size, amp:note.amplitude
        end
        if polycursor + 1 < line.size()
          ended = false
        end
      end
    end
    puts("sleeping "+step_size.to_s)
    sleep step_size
    polycursor+=1
  end
end

# play_notes("AAA/BBB/CCC")

live_loop :tick do
    cue :tick
    sleep 0.25
end


in_thread(name: :lead1) do
  loop do
  sync :tick
    with_fx :echo, mix: 0.3, phase: 0.0, amp: 0.4 do
      use_synth :beep
      play_notes "> 5 7 0 5 / 0 - - - 0 - - -", step_size=0.25, shift=0
    end
  end
end


p1 = "> > * 0 0 < 7 12 12 12 / > 7 7 7 * * *"
live_loop :lead2 do
  sync :tick
    with_fx :reverb, mix: 0.1, amp: 0.2 do
      use_synth :beep
      play_notes p1, step_size=0.25, shift=0
    end
end


live_loop :bass do
  sync :tick
  with_fx :reverb, mix: 0.3, phase: 0.25 do
    use_synth :fm
    play_notes "> 0 - 0 ", step_size=0.25, shift=0
  end
end