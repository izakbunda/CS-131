import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.util.zip.CRC32;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.LinkedBlockingQueue;

import java.util.concurrent.ThreadPoolExecutor;


public class Pigzj {

    public final static int blockSize = 1024 * 128;
    public final static int dictionarySize = 1024 * 32;

    /* HEADER */
    private static final byte[] defaultHeader = new byte[]{31, -117, 8, 0, 0, 0, 0, 0, 0, -1};

    /* THREAD ARRAY AND POOL */
    private static final List<CompressionThread> allThreads = new ArrayList<>();
    private static ThreadPoolExecutor threads;

    /* BLOCK ARRAY */
    private static final List<byte[]> blocks = new ArrayList<>();
    private static int blockNum = 0;

    /* TRAILER */
    private static final CRC32 crc = new CRC32();
    private static final byte[] trailerBytes = new byte[8];
    private static int crcValue; // not long so make sure to cast
    private static int totalLength;

    public static int processors;

    /* CREDITS TO MESSADMIN https://github.com/MessAdmin/MessAdmin-Core/blob/master/src/main/java/clime/messadmin/utils/compress/gzip/GZipFileStreamUtil.java#L130 tysm <3 */

    /* Writes integer in Intel byte order to a byte array, starting at a given offset. */
	private static void writeInt(int i, byte[] buf, int offset) throws IOException {
		writeShort(i & 0xffff, buf, offset);
		writeShort((i >> 16) & 0xffff, buf, offset + 2);
	}

	/* Writes short integer in Intel byte order to a byte array, starting at a given offset */
	private static void writeShort(int s, byte[] buf, int offset) throws IOException {
		buf[offset] = (byte)(s & 0xff);
		buf[offset + 1] = (byte)((s >> 8) & 0xff);
	}

    public static void processBlock(byte[] blockData, boolean isLast) {
        // CompressionThread(byte[] block, byte[] prevBlock, int blockLength, int prevBlockLength, boolean firstBlock, boolean isLast )
        CompressionThread t = new CompressionThread(
            blockData, 
            blockNum > 0 ? blocks.get(blockNum - 1) : new byte[0], 
            blockData.length, 
            blockNum > 0 ? blocks.get(blockNum - 1).length : 0, 
            blockNum == 0,
            isLast
        );

        threads.execute(t);
        allThreads.add(t);
    }

    public static void getArguments(String[] args) {
        if (args.length == 0) {
            processors = Runtime.getRuntime().availableProcessors();
        } 
        else if (args.length == 2 && args[0].equals("-p")) {
            boolean isNumeric = args[1].matches("-?\\d+");

            if (isNumeric) {
                int second_arg = Integer.parseInt(args[1]); 

                // check if too many processors
                if (second_arg > 4 * (Runtime.getRuntime().availableProcessors())) {
                    System.err.println("Error: Too many processors!");
                    System.exit(1);
                }

                processors = second_arg;
            } else {
                // Handle case where the argument following -p is not an integer
                System.err.println("Error: Incorrect arguments!");
                System.exit(1);
            }
        }
        else {
            System.err.println("Error: Incorrect arguments!");
            System.exit(1);
        }
    }

    public static void main(String[] args) throws IOException {

        ByteArrayOutputStream inputStream = new ByteArrayOutputStream();

        /* BUFFER AND DICTIONARY */
        byte[] buffer = new byte[blockSize];
        byte[] dictionary = new byte[dictionarySize];

        int bytesRead = 0;
        int unprocessedBytes = 0;

        getArguments(args);
        // declared above so its available to processBlock
        // public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue)
        // Creates a new ThreadPoolExecutor with the given initial parameters and default thread factory and rejected execution handler. 
        // NOTE: workQueue - the queue to use for holding tasks before they are executed. This queue will hold only the Runnable tasks submitted by the execute method.
        threads = new ThreadPoolExecutor(processors, processors, Long.MAX_VALUE, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());

        /* HEADER */
        System.out.write(defaultHeader);

        /* ERROR HANDLERS FOR FAIL2 TESTS */
        if (System.out.checkError()) {
            System.err.println("System error on stdout!");
            System.exit(1);
        }
    
        // reads the next byte from stdin
        // weird that this is int, but basically it is
        while ((bytesRead = System.in.read(buffer)) > 0) {

            // We have to do this because Sytem.in.read(block) isn’t guaranteed to read the entire block at a time
            // like it could be reading less/more than the block size so we wanna make sure

            // calculate total bytes available 
            int totalAvailableBytes = bytesRead + unprocessedBytes;

            if (totalAvailableBytes >= blockSize) {

                // Writes len bytes from the specified byte array starting at offset off to this byte array output stream.
                // public void write(byte[] b, int off, int len)
                // b - the data.
                // off - the start offset in the data.
                // len - the number of bytes to write.
                inputStream.write(buffer, 0, blockSize - unprocessedBytes);

                crc.update(inputStream.toByteArray(), 0, blockSize);

                // I made a list of blocks because I need to get the previous block AFTER the first block
                // so that I could make a dictionary for the current block (after the first block)
                blocks.add(inputStream.toByteArray());
                
                // processBlock(byte[] blockData, boolean isLast)
                processBlock(inputStream.toByteArray(), false);
                
                // Resets the count field of this byte array output stream to zero, so that all currently accumulated output in the output stream is discarded.
                inputStream.reset();
                
                // calculate total bytes available after subtracting the block size
                unprocessedBytes = totalAvailableBytes - blockSize;

                // then put that back into the inputstream because we have to use that for the next block
                inputStream.write(buffer, blockSize - unprocessedBytes, unprocessedBytes);
                
                blockNum++; 
            } else {
                unprocessedBytes = unprocessedBytes + bytesRead; 
                inputStream.write(buffer, 0, bytesRead);
            }

            // this is for the trailer bc we can't do deflater.getTotalIn(); since we moved it out to CompressionThread
            totalLength += bytesRead;
        }

        // If we make it to the end AND unprocessedBytes > 0 then that means that we have extra this is so important
        // We need this or we will get data--length error because the wrong part of the data will get deflater.finish()
        // and the compression will be wrong
        if (unprocessedBytes > 0) {

            // EVERYTHING in here is the same, except for the second argument to processBlock (isLast = true)

            crc.update(inputStream.toByteArray(), 0, unprocessedBytes);
            blocks.add(inputStream.toByteArray());
            processBlock(inputStream.toByteArray(), true);
        } else if (blocks.size() > 0) {
            // if all data fits into blocks, set last seen block to be last
            allThreads.get(allThreads.size() - 1).lastBlock = true;
        }

        if (blocks.size() == 0) {
            System.err.println("Empty file error!");
            System.exit(1);
        }

        threads.shutdown(); 

        for (CompressionThread t : allThreads) {
            try {
                synchronized (t) {
                    while(!t.doneWithOutput) {
                        t.wait();
                    }
                }      
                System.out.write(t.blockOutput, 0, t.totalLengthCompressed);
                t.blockOutput = null;
            } catch (InterruptedException err) {
                System.err.println("Interrupted Exception error!");
                System.exit(1);
            }
        }

        // The first 4 bytes should store an integer that is the result from your checksum operations:
        crcValue = (int) crc.getValue();
        writeInt(crcValue, trailerBytes, 0);

        // last four bytes: just use total
        writeInt(totalLength, trailerBytes, 4); 

        // Naively append to the end
        System.out.write(trailerBytes);
    }
}

 // while ((bytesRead = System.in.read(buffer, unprocessedBytes, blockSize - unprocessedBytes)) != -1) {
        //     unprocessedBytes += bytesRead;
        //     totalLength += bytesRead;

        //     if (unprocessedBytes == blockSize) {
        //         processBlock(outputStream.toByteArray(), false);
        //         unprocessedBytes = 0; // Reset for the next block
        //         outputStream.reset(); // Clear the buffer
        //     } else {
        //         outputStream.write(buffer, 0, bytesRead);
        //     }

        //     // Process any remaining bytes
        //     if (unprocessedBytes > 0) {
        //         // System.out.println("PIGZJ: FINISHED LAST BLOCK");
        //         processBlock(outputStream.toByteArray(), true); // isLast is set to true
        //     }

        // }