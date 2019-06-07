#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <mach/mach.h>
#include <IOKit/IOKitLib.h>

int main(int argc, char** argv, char** envp)
{
	if (argc < 2)
	{
		printf("Incorrect Usage\nUsage: ioservice [service name]\n");
		return -1;
	}
	char* service_name = argv[1];
	
	kern_return_t kr;
	NSMutableOrderedSet* foundClients = [NSMutableOrderedSet new];

	//loop through every IOService:
	io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(service_name));
	
	if (service != IO_OBJECT_NULL)
	{
		//open first 10 clients:
		io_connect_t conns[10];
		for (int i = 0; i < 10; i++)
		{
			conns[i] = IO_OBJECT_NULL;
			kr = IOServiceOpen(service, mach_task_self(), i, &(conns[i]));
		}

		//loop through registry entries:
		io_iterator_t children;
		kr = IORegistryEntryGetChildIterator(service, kIOServicePlane, &children);
		
		io_registry_entry_t child;
		while (children != IO_OBJECT_NULL && (child = IOIteratorNext(children)))
		{
			io_name_t child_name;
			IORegistryEntryGetName(child, child_name);
			[foundClients addObject:[NSString stringWithUTF8String:child_name]];
		}
		
		//release our children iterator:
		if (children != IO_OBJECT_NULL)
			IOObjectRelease(children);

		//close clients again:
		for (int i = 0; i < 10; i++)
		{
			if (conns[i])
				IOServiceClose(conns[i]);
		}
	}

	//print all matching clients:
	if (foundClients.count == 0)
	{
		printf("Unable to find clients for service: %s\n", service_name);
	}
	else
	{
		for (int i = 0; i < foundClients.count; i++)
		{
			printf("%s\n", [foundClients[i] UTF8String]);
		}
	}

	return 0;
}
