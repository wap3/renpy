# Copyright 2004-2016 Tom Rothamel <pytom@bishoujo.us>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

from pygame_sdl2 cimport *
import_pygame_sdl2()

cdef extern from "renpysound_core.h":

    void RPS_play(int channel, SDL_RWops *rw, char *ext, object name, int fadein, int tight, int paused)
    void RPS_queue(int channel, SDL_RWops *rw, char *ext, object name, int fadein, int tight)
    void RPS_stop(int channel)
    void RPS_dequeue(int channel, int even_tight)
    int RPS_queue_depth(int channel)
    object RPS_playing_name(int channel)
    void RPS_fadeout(int channel, int ms)
    void RPS_pause(int channel, int pause)
    void RPS_unpause_all()
    int RPS_get_pos(int channel)
    void RPS_set_endevent(int channel, int event)
    void RPS_set_volume(int channel, float volume)
    float RPS_get_volume(int channel)
    void RPS_set_pan(int channel, float pan, float delay)
    void RPS_set_secondary_volume(int channel, float vol2, float delay)

    void RPS_sample_surfaces(object, object)
    void RPS_init(int freq, int stereo, int samples, int status)
    void RPS_quit()

    void RPS_periodic()
    void RPS_alloc_event(object)
    int RPS_refresh_event()

    char *RPS_get_error()


def check_error():
    e = RPS_get_error();

    if str(e):
        raise Exception(e)

def play(channel, file, name, paused=False, fadein=0, tight=False):
    cdef SDL_RWops *rw

    rw = RWopsFromPython(file)

    if rw == NULL:
        raise Exception("Could not create RWops.")

    if paused:
        pause = 1
    else:
        pause = 0

    if tight:
        tight = 1
    else:
        tight = 0

    extension = name.encode("utf-8")
    RPS_play(channel, rw, extension, name, fadein, tight, pause)
    check_error()

def queue(channel, file, name, fadein=0, tight=False):
    cdef SDL_RWops *rw

    rw = RWopsFromPython(file)

    if rw == NULL:
        raise Exception("Could not create RWops.")

    if tight:
        tight = 1
    else:
        tight = 0

    extension = name.encode("utf-8")
    RPS_queue(channel, rw, extension, name, fadein, tight)
    check_error()

def stop(channel):
    RPS_stop(channel)
    check_error()

def dequeue(channel, even_tight=False):
    RPS_dequeue(channel, even_tight)

def queue_depth(channel):
    return RPS_queue_depth(channel)

def playing_name(channel):
    return RPS_playing_name(channel)

def pause(channel):
    RPS_pause(channel, 1)
    check_error()

def unpause(channel):
    RPS_pause(channel, 0)
    check_error()

def unpause_all():
    RPS_unpause_all()

def fadeout(channel, ms):
    RPS_fadeout(channel, ms)
    check_error()

def busy(channel):
    return RPS_get_pos(channel) != -1

def get_pos(channel):
    return RPS_get_pos(channel)

def set_volume(channel, volume):
    if volume == 0:
        RPS_set_volume(channel, 0)
    else:
        RPS_set_volume(channel, volume ** 2)

    check_error()

def set_pan(channel, pan, delay):
    RPS_set_pan(channel, pan, delay)
    check_error()

def set_secondary_volume(channel, volume, delay):
    RPS_set_secondary_volume(channel, volume, delay)
    check_error()

def set_end_event(channel, event):
    RPS_set_endevent(channel, event)
    check_error()

def get_volume(channel):
    return RPS_get_volume(channel)

def init(freq, stereo, samples, status=False):
    if status:
        status = 1
    else:
        status = 0

    RPS_init(freq, stereo, samples, status)
    check_error()

def quit(): # @ReservedAssignment
    RPS_quit()

def periodic():
    RPS_periodic()

# Store the sample surfaces so they stay alive.
rgb_surface = None
rgba_surface = None

def sample_surfaces(rgb, rgba):
    global rgb_surface
    global rgba_surface

    rgb_surface = rgb
    rgba_surface = rgb

    RPS_sample_surfaces(rgb, rgba)

def alloc_event(surf):
    RPS_alloc_event(surf)

def refresh_event():
    return RPS_refresh_event()

def needs_alloc():
    # return ffpy_needs_alloc
    return False

def movie_size():
    return 0, 0
    # return ffpy_movie_width, ffpy_movie_height

def check_version(version):
    if version < 2 or version > 4:
        raise Exception("pysdlsound version mismatch.")