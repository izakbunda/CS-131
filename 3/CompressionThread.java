import java.io.IOException;
import java.util.zip.Deflater;
import java.util.zip.CRC32;
import java.io.ByteArrayOutputStream;
import java.util.Arrays;

// DEFLATER DOCUMENTATION: https://docs.oracle.com/javase/8/docs/api/java/util/zip/Deflater.html 
// CRC32 DOCUMENTATION: https://docs.oracle.com/javase/8/docs/api/java/util/zip/CRC32.html

public class CompressionThread implements Runnable {

    // constructor variables
    private byte[] block;
    private byte[] prevBlock;
    private int blockLength;
    private int prevBlockLength;
    private boolean firstBlock;

    private byte[] dictionary;

    // public (stuff Pigzj can read)
    public int totalLengthCompressed;
    public byte[] blockOutput;
    public volatile boolean doneWithOutput;
    public boolean lastBlock;

    public void run() {
        this.compression();
    }

    /* SYNCHRONIZED FOR CONCURRENCY */
    private synchronized void setDoneWithOutput() {
        doneWithOutput = true;
        notify(); // this is needed or else the other t's will not know if this one is done or not
    }

    public void setLast(boolean bool) {
        this.lastBlock = bool;
    }

    // constructor
    public CompressionThread(byte[] block, byte[] prevBlock, int blockLength, int prevBlockLength, boolean firstBlock, boolean isLast) {   
        this.block = block;
        this.prevBlock = prevBlock;
        this.blockLength = blockLength;
        this.prevBlockLength = prevBlockLength;
        this.firstBlock = firstBlock;
        this.lastBlock = isLast;

        if (prevBlockLength > 32*1024) {
            dictionary = Arrays.copyOfRange(prevBlock, prevBlockLength - 32*1024, prevBlockLength);
        }
    }

    public void compression() {
        Deflater deflater = new Deflater(-1, true);

        if (!firstBlock && dictionary != null) {
            deflater.setDictionary(dictionary); // Only set dictionary if it's not null
        }   


        deflater.setInput(block, 0, blockLength);

        if (lastBlock) {
            // System.out.println("COMPTHREAD: FINISHED LAST BLOCK");
            deflater.finish(); // only call on final block
        }

        byte[] outputBuffer = new byte[2*128*1024];
        ByteArrayOutputStream compressionStream = new ByteArrayOutputStream();

        int compressionReadBytes;

        while ((compressionReadBytes = deflater.deflate(outputBuffer, 0, outputBuffer.length, Deflater.SYNC_FLUSH)) > 0) {
            compressionStream.write(outputBuffer, 0, compressionReadBytes);
            totalLengthCompressed += compressionReadBytes;
        }

        blockOutput = compressionStream.toByteArray();
        
        setDoneWithOutput();
    }
}


// public class CompressionThread {

//     private static final byte[] default_header = new byte[]{31, -117, 8, 0, 0, 0, 0, 0, 0, -1};

//     /* CREDITS TO MESSADMIN https://github.com/MessAdmin/MessAdmin-Core/blob/master/src/main/java/clime/messadmin/utils/compress/gzip/GZipFileStreamUtil.java#L130 tysm <3 */

//     /**
// 	 * Writes integer in Intel byte order to a byte array, starting at a
// 	 * given offset.
// 	 */
// 	private static void writeInt(int i, byte[] buf, int offset) throws IOException {
// 		writeShort(i & 0xffff, buf, offset);
// 		writeShort((i >> 16) & 0xffff, buf, offset + 2);
// 	}

// 	/**
// 	 * Writes short integer in Intel byte order to a byte array, starting
// 	 * at a given offset
// 	 */
// 	private static void writeShort(int s, byte[] buf, int offset) throws IOException {
// 		buf[offset] = (byte)(s & 0xff);
// 		buf[offset + 1] = (byte)((s >> 8) & 0xff);
// 	}

//     public static void main(String[] args) { // This is like int main() {...} in C++

//         int numThreads = Runtime.getRuntime().availableProcessors();

//         CRC32 crc = new CRC32();
//         Deflater deflater = new Deflater(-1, true);

//         // set dictionary stuff ?
//         // do this later when we are dividing up the file into chunks
//         // remember that the first chunk does not need a dictionary, 
//         // but the next chunks will use the previous chunk's dictionary
//         // to speed things up

//         byte[] buffer = new byte[1024*128]; // 1024 = KiB of data is standard ? idk
//         // byte[] dictionary = new byte[1024*32]

//         int bytesRead;

//         try {

//             /* HEADER */
//             System.out.write(default_header);

//             // reads the next byte from stdin
//             // weird that this is int, but basically it 
//             while ((bytesRead = System.in.read(buffer)) != -1) {

//                 // Sytem.in.read() returns -1 at the end of the buffer so this will take us to the end

//                 // System.out.println(bytesRead);

//                 /* CRC.UPDATE() */
//                 // update(byte[] b, int off, int len) – Updates the CRC-32 checksum with the specified array of bytes.
//                 // b - the byte array to update the checksum with
//                 // off - the start offset of the data
//                 // len - the number of bytes to use for the update

//                 // In order to make sure that the checksum for the our compressed file will
//                 // be valid for the gzip decompressor, we need to update it at every byte

//                 crc.update(buffer, 0, bytesRead); 

//                 /* DEFLATER.SETINPUT() */
//                 // setInput(byte[] b, int off, int len) – Sets input data for compression.

//                 deflater.setInput(buffer, 0, bytesRead);

//                 // needsInput() – Returns true if the input data buffer is empty
//                 while (!deflater.needsInput()) {

//                     // Even though the compressed data is going to be smaller than the 1024 bytes,
//                     // it's okay to set compressedData to be the same size because we are certain
//                     // that it won't be bigger than 1024 bytes
//                     byte[] compressedData = new byte[1024]; 
//                     int compressedBytes = deflater.deflate(compressedData); // Compresses the input data and fills specified buffer with compressed data.


//                     System.out.write(compressedData, 0, compressedBytes);
//                 }
    
//             }

//             // When called, indicates that compression should end with the current contents of the input buffer.
//             // This doesn't mean that the deflater input buffer is empty we're basically just saying that we're not
//             // going to write into it anymore

//             deflater.finish(); 

//             // So we have to check if there are anything left in there

//             while (!deflater.finished()) { // Returns true if the end of the compressed data output stream has been reached.

//                 // same things as before:

//                 byte[] compressedData = new byte[1024];
//                 int compressedBytes = deflater.deflate(compressedData);
//                 System.out.write(compressedData, 0, compressedBytes);
//             }


//             /* TRAILER */
//             byte[] trailerBytes = new byte[8];

//             int crcValue; // not long so make sure to cast
//             int trailer;

//             // The first 4 bytes should store an integer that is the result from your checksum operations:
//             crcValue = (int) crc.getValue();

//             // last four bytes:
//             //  The next 4 bytes should store an integer that is the size of the original, uncompressed input.
//             trailer = deflater.getTotalIn();

//             // CONVERT TO BYTE ARRAY
//             writeInt(crcValue, trailerBytes, 0);
//             writeInt(trailer, trailerBytes, 4); 

//             // Naively append to the end
//             System.out.write(trailerBytes);


//         } catch (IOException e) {
//             e.printStackTrace();
//         } finally {

//             /* DEFLATER.END() */
//             // Closes the compressor and discards any unprocessed input. This method should be
//             // called when the compressor is no longer being used, but will also be called automatically
//             // by the finalize() method. Once this method is called, the behavior of the Deflater object is undefined.

//             deflater.end();
//         }
//     }
// }

// // make sure blocks work with one thread
// // executer services and executers and thread pools