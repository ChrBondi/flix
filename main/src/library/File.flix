/*
 * Copyright 2021 Magnus Madsen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
namespace File {

    ///
    /// File types.
    ///
    pub enum FileType with Eq, Order, ToString {
        case File,
        case Directory,
        case SymLink,
        case Other
    }

    ///
    /// Returns the last access time of the given file `f` in milliseconds.
    ///
    pub def accessTime(f: String): Result[Int64, String] & Impure =
        try {
            use Result.flatMap;
            import java.nio.file.attribute.BasicFileAttributes.lastAccessTime(): ##java.nio.file.attribute.FileTime & Impure;
            import java.nio.file.attribute.FileTime.toMillis(): Int64 & Impure;

            let* fileAttributes = getAttributes(f);
            let timeLastAccess = lastAccessTime(fileAttributes);
            let inMilliSec = toMillis(timeLastAccess);

            Ok(inMilliSec)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns the creation time of the given file `f` in milliseconds.
    ///
    pub def creationTime(f: String): Result[Int64, String] & Impure =
        try {
            use Result.flatMap;
            import java.nio.file.attribute.BasicFileAttributes.creationTime(): ##java.nio.file.attribute.FileTime & Impure;
            import java.nio.file.attribute.FileTime.toMillis(): Int64 & Impure;

            let* fileAttributes = getAttributes(f);
            let timeCreated = creationTime(fileAttributes);
            let inMilliSec = toMillis(timeCreated);

            Ok(inMilliSec)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns the last-modified timestamp of the given file `f` in milliseconds
    ///
    pub def modificationTime(f: String): Result[Int64, String] & Impure =
        try {
            use Result.flatMap;
            import java.nio.file.attribute.BasicFileAttributes.lastModifiedTime(): ##java.nio.file.attribute.FileTime & Impure;
            import java.nio.file.attribute.FileTime.toMillis(): Int64 & Impure;

            let* fileAttributes = getAttributes(f);
            let timeLastModified = lastModifiedTime(fileAttributes);
            let inMilliSec = toMillis(timeLastModified);

            Ok(inMilliSec)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns the size of the given file `f` in bytes.
    ///
    pub def size(f: String): Result[Int64, String] & Impure =
        try {
            use Result.flatMap;
            import java.nio.file.attribute.BasicFileAttributes.size(): Int64 & Impure;

            let* fileAttributes = getAttributes(f);
            let fileSize = size(fileAttributes);

            Ok(fileSize)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns the BacisFileAttributes of the file `f`.
    ///
    def getAttributes(f: String): Result[##java.nio.file.attribute.BasicFileAttributes, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.readAttributes(##java.nio.file.Path, ##java.lang.Class, Array[##java.nio.file.LinkOption]): ##java.nio.file.attribute.BasicFileAttributes & Impure;
            import static java.lang.Class.forName(String): ##java.lang.Class & Impure;

            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let classOfAttributes = forName("java.nio.file.attribute.BasicFileAttributes");

            Ok(readAttributes(javaPath, classOfAttributes, []))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns the type of the given file `f`.
    ///
    pub def fileType(f: String): Result[FileType, String] & Impure =
        use Result.flatMap;

        let* isFile = File.isRegularFile(f);
        let* isDirec = File.isDirectory(f);
        let* isSymLink = File.isSymbolicLink(f);

        if (isFile)         Ok(FileType.File)
        else if (isDirec)   Ok(FileType.Directory)
        else if (isSymLink) Ok(FileType.SymLink)
        else                Ok(FileType.Other)

    ///
    /// Statistical information for a file.
    ///
    pub type alias StatInfo = {
        accessTime       :: Int64,
        creationTime     :: Int64,
        modificationTime :: Int64,
        size             :: Int64,
        fileType         :: FileType
    }

    ///
    /// Returns the statistics of the given file `f`.
    ///
    pub def stat(f: String): Result[StatInfo, String] & Impure =
        use Result.flatMap;

        let* fileAccessTime = accessTime(f);
        let* fileCreationTime = creationTime(f);
        let* fileModificationTime = modificationTime(f);
        let* fileSize = size(f);
        let* typeOfFile = fileType(f);

        Ok({
            accessTime = fileAccessTime,
            creationTime = fileCreationTime,
            modificationTime = fileModificationTime,
            size = fileSize,
            fileType = typeOfFile
        })

    ///
    /// Returns `true` if the given file `f` exists.
    ///
    pub def exists(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.exists(): Bool & Impure;
            Ok(exists(newFile(f)))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` is the given file `f` is a directory.
    ///
    pub def isDirectory(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.isDirectory(): Bool & Impure;
            Ok(isDirectory(newFile(f)))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` if the given file `f` is a regular file.
    ///
    pub def isRegularFile(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.isRegularFile(##java.nio.file.Path, Array[##java.nio.file.LinkOption]): Bool & Impure;
            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let isRegular = isRegularFile(javaPath, []);
            Ok(isRegular)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` if the given file `f` is readable.
    ///
    pub def isReadable(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.canRead(): Bool & Impure;
            Ok(canRead(newFile(f)))
        } catch {
            case _: ##java.io.IOException => Err("I/O Error")
        }

    ///
    /// Returns `true` if the given file `f` is a symbolic link.
    ///
    pub def isSymbolicLink(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.isSymbolicLink(##java.nio.file.Path): Bool & Impure;
            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let isSymbolic = isSymbolicLink(javaPath);
            Ok(isSymbolic)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` if the given file `f` is writable.
    ///
    pub def isWritable(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.canWrite(): Bool & Impure;
            Ok(canWrite(newFile(f)))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` if the given file `f` is executable.
    ///
    pub def isExecutable(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.canExecute(): Bool & Impure;
            Ok(canExecute(newFile(f)))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns a string containing the given file `f`.
    ///
    pub def read(f: String): Result[String, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.readString(##java.nio.file.Path): String & Impure;
            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let result = readString(javaPath);
            Ok(result)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns a string containing the given file `f` with the options `opts`.
    /// The options `opts` to apply consists of
    /// `offset` - the start offset in the given file `f`.
    /// `count` - the number of bytes read.
    /// `charSet` - the specific charset to be used to decode the bytes.
    ///
    pub def readWith(opts: {offset :: Int64, count :: Int32, charSet :: String}, f : String): Result[String, String] & Impure = {
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileInputStream(##java.io.File): ##java.io.FileInputStream & Impure as newInputStream;
            import java.io.FileInputStream.skip(Int64): Int64 & Impure;
            import java.io.FileInputStream.read(Array[Int8], Int32, Int32): Int32 & Impure;
            import static java.nio.charset.Charset.forName(String): ##java.nio.charset.Charset & Impure;
            import new java.lang.String(Array[Int8], ##java.nio.charset.Charset): String & Impure as newString;

            let javaFile = newFile(f);
            let stream = newInputStream(javaFile);
            skip(stream, opts.offset);
            let bytes = [0i8; opts.count];
            read(stream, bytes, 0, opts.count);
            let charSet = forName(opts.charSet);
            let returnString = newString(bytes, charSet);
            Ok(returnString)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }
    }

    ///
    /// Returns a list of all the lines in the given file `f`.
    ///
    pub def readLines(f: String): Result[List[String], String] & Impure = try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.newBufferedReader(##java.nio.file.Path): ##java.io.BufferedReader & Impure;
            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let reader = newBufferedReader(javaPath);
            Ok(readAll(reader))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Reads all lines from the given buffered reader `r` until it is empty.
    ///
    def readAll(r: ##java.io.BufferedReader): List[String] & Impure =
        import java.io.BufferedReader.readLine(): String & Impure;
        def loop(k) = {
            let l = readLine(r);
            if (Object.isNull(l))
                k(Nil)
            else
                loop(ks -> k(l :: ks))
        };
        loop(identity)

    ///
    /// Returns a list of all the lines in the given file `f` with the options `opts`.
    /// The options `opts` to apply consists of
    /// `charSet` - the specific charset to be used to decode the bytes.
    ///
    pub def readLinesWith(opts: {charSet :: String}, f: String): Result[List[String], String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.newBufferedReader(##java.nio.file.Path, ##java.nio.charset.Charset): ##java.io.BufferedReader & Impure;
            import static java.nio.charset.Charset.forName(String): ##java.nio.charset.Charset & Impure;

            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let reader = newBufferedReader(javaPath, forName(opts.charSet));
            Ok(readAll(reader))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns an iterator of the given file `f`
    ///
    pub def readLinesIter(f: String): Iterator[Result[String, String]] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.newBufferedReader(##java.nio.file.Path): ##java.io.BufferedReader & Impure;
            import java.io.BufferedReader.readLine(): String & Impure;

            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let reader = newBufferedReader(javaPath);
            let line = ref readLine(reader);

            let done = () -> Object.isNull(deref line);
            let next = () -> {
                try {
                    let l = deref line;
                    line := readLine(reader);
                    Ok(l)
                } catch {
                    case ex: ##java.io.IOException => {
                        line := null as String;
                        import java.lang.Throwable.getMessage(): String & Impure;
                        Err(getMessage(ex))
                    }
                }
            };
            Iterator(done, next)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Iterator.singleton(Err(getMessage(ex)))
        }

    ///
    /// Returns an iterator of the given file `f` with the options `opts`.
    /// The options `opts` to apply consists of
    /// `charSet` - the specific charset to be used to decode the bytes.
    ///
    pub def readLinesIterWith(opts: {charSet :: String}, f: String): Iterator[Result[String, String]] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.newBufferedReader(##java.nio.file.Path, ##java.nio.charset.Charset): ##java.io.BufferedReader & Impure;
            import static java.nio.charset.Charset.forName(String): ##java.nio.charset.Charset & Impure;
            import java.io.BufferedReader.readLine(): String & Impure;

            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let reader = newBufferedReader(javaPath, forName(opts.charSet));
            let line = ref readLine(reader);

            let done = () -> Object.isNull(deref line);
            let next = () -> {
                try {
                    let l = deref line;
                    line := readLine(reader);
                    Ok(l)
                } catch {
                    case ex: ##java.io.IOException => {
                        line := null as String;
                        import java.lang.Throwable.getMessage(): String & Impure;
                        Err(getMessage(ex))
                    }
                }
            };
            Iterator(done, next)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Iterator.singleton(Err(getMessage(ex)))
        }

    ///
    /// Returns an array of all the bytes in the given file `f`.
    ///
    pub def readBytes(f: String): Result[Array[Int8], String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.toPath(): ##java.nio.file.Path & Impure;
            import static java.nio.file.Files.readAllBytes(##java.nio.file.Path): Array[Int8] & Impure;

            let javaFile = newFile(f);
            let javaPath = toPath(javaFile);
            let bytes = readAllBytes(javaPath);

            Ok(bytes)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns an array of all the bytes in the given file `f` and applying the options `opts`.
    /// The options `opts` to apply consists of
    /// `offset` - the start offset in the given file `f`.
    /// `count` - the number of bytes read.
    ///
    pub def readBytesWith(opts: {offset :: Int64, count :: Int32}, f: String): Result[Array[Int8], String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileInputStream(##java.io.File): ##java.io.FileInputStream & Impure as newInputStream;
            import java.io.FileInputStream.skip(Int64): Int64 & Impure;
            import java.io.FileInputStream.read(Array[Int8], Int32, Int32): Int32 & Impure;

            let javaFile = newFile(f);
            let stream = newInputStream(javaFile);
            skip(stream, opts.offset);
            let bytes = [0i8; opts.count];
            let numberRead = read(stream, bytes, 0, opts.count);

            let res = readBytesWithHelper(bytes, numberRead, opts.count);

            Ok(res)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Helper function for `readBytesWith`.
    /// Returns an array that corresponds to the bytes actually read from the stream.
    ///
    def readBytesWithHelper(bytes: Array[Int8], numberRead: Int32, count: Int32): Array[Int8] & Impure =
        let nothingRead = (numberRead == -1);
        if (nothingRead) {
            []
        } else {
            let countBiggest = numberRead < count;
            if (countBiggest) {
                Array.slice(0, numberRead, bytes)
            } else {
                bytes
            }
        }

    ///
    /// Returns an iterator of the bytes in the given `file` in chunks of size `chunkSize`.
    ///
    pub def readChunks(f: String, chunkSize: Int32): Iterator[Result[Array[Int8], String]] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileInputStream(##java.io.File): ##java.io.FileInputStream & Impure as newInputStream;
            import java.io.FileInputStream.read(Array[Int8]): Int32 & Impure;

            let javaFile = newFile(f);
            let stream = newInputStream(javaFile);
            let bytes = ref [0i8; chunkSize];
            let numberRead = ref read(stream, deref bytes);

            let done = () -> deref numberRead == -1;
            let next = () -> {
                try {
                    let chunk = deref bytes;
                    bytes := [0i8; chunkSize];
                    let accRead = deref numberRead;
                    numberRead := read(stream, deref bytes);
                    Ok(readBytesWithHelper(chunk, accRead, chunkSize))
                } catch {
                    case ex: ##java.io.IOException => {
                        numberRead := -1;
                        import java.lang.Throwable.getMessage(): String & Impure;
                        Err(getMessage(ex))
                    }
                }
            };
            Iterator(done, next)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Iterator.singleton(Err(getMessage(ex)))
        }

    ///
    /// Writes `data` to the given file `f`.
    ///
    /// Creates file `f` if it does not exist. Overwrites it if it exists.
    ///
    /// Returns `true` if the file was created.
    ///
    pub def write(f: String, data: t): Result[Bool, String] & Impure with ToString[t] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.PrintWriter(##java.io.File): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.PrintWriter.println(String): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            let w = newPrintWriter(javaFile);

            println(w, "${data}");
            close(w);

            if (checkError(w)) {
                Err("An error occurred when writing to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Writes `data` to the given `f`.
    ///
    /// Creates `f` if it does not exist. Overwrites it if it exists.
    ///
    /// Returns `true` if the file `f` was created, and `false` if `f` was overwritten.
    ///
    pub def writeLines(f: String, data: f[String]): Result[Bool, String] & Impure with Foldable[f] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.PrintWriter(##java.io.File): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.PrintWriter.println(String): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            let w = newPrintWriter(javaFile);

            Foldable.foreach(line -> println(w, line), data);
            close(w);

            if (checkError(w)) {
                Err("An error occurred when writing lines to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Appends `data` to the given file `f`.
    ///
    /// Returns `true` if the file `f` was created, and `false` if `data` was appended to an existing `f`.
    ///
    pub def append(f: String, data: t): Result[Bool, String] & Impure with ToString[t] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileWriter(##java.io.File, Bool): ##java.io.FileWriter & Impure as newFileWriter;
            import new java.io.PrintWriter(##java.io.Writer): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.PrintWriter.println(String): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            // 2nd parameter `true` is for append.
            let fileWriter = newFileWriter(javaFile, true);
            let printWriter = newPrintWriter(fileWriter as ##java.io.Writer);

            println(printWriter, "${data}");
            close(printWriter);

            if (checkError(printWriter)) {
                Err("An error occurred when appending to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Appends `data` to the given file `f`.
    ///
    /// Returns `true` if the file `f` was created, and `false` if `data` was appended to an existing `f`.
    ///
    pub def appendLines(f: String, data: f[String]): Result[Bool, String] & Impure with Foldable[f] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileWriter(##java.io.File, Bool): ##java.io.FileWriter & Impure as newFileWriter;
            import new java.io.PrintWriter(##java.io.Writer): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.PrintWriter.println(String): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            // 2nd parameter `true` is for append.
            let fileWriter = newFileWriter(javaFile, true);
            let printWriter = newPrintWriter(fileWriter as ##java.io.Writer);

            Foldable.foreach(line -> println(printWriter, line), data);
            close(printWriter);

            if (checkError(printWriter)) {
                Err("An error occurred when appending lines to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Writes `data` to the given `f`.
    ///
    /// Creates `f` if it does not exist. Overwrites it if it exists.
    ///
    /// Returns `true` if the file `f` was created, and `false` if `f` was overwritten.
    ///
    pub def writeBytes(f: String, data: f[Int8]): Result[Bool, String] & Impure with Foldable[f] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileOutputStream(##java.io.File): ##java.io.FileOutputStream & Impure as newFileStream;
            import new java.io.PrintWriter(##java.io.OutputStream): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.FileOutputStream.write(Array[Int8]): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            let fileStream = newFileStream(javaFile);
            let printWriter = newPrintWriter(fileStream as ##java.io.OutputStream);

            let dataAsArray = Foldable.toArray(data);
            write(fileStream, dataAsArray);
            close(printWriter);

            if (checkError(printWriter)) {
                Err("An error occurred when writing to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Appends `data` to the given `f`.
    ///
    /// Returns `true` if the file `f` was created, and `false` if `data` was appended to an existing `f`.
    ///
    pub def appendBytes(f: String, data: f[Int8]): Result[Bool, String] & Impure with Foldable[f] =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.FileOutputStream(##java.io.File, Bool): ##java.io.FileOutputStream & Impure as newFileStream;
            import new java.io.PrintWriter(##java.io.OutputStream): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.FileOutputStream.write(Array[Int8]): Unit & Impure;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            // 2nd parameter `true` is for append.
            let fileStream = newFileStream(javaFile, true);
            let printWriter = newPrintWriter(fileStream as ##java.io.OutputStream);

            let dataAsArray = Foldable.toArray(data);
            write(fileStream, dataAsArray);

            close(printWriter);

            if (checkError(printWriter)) {
                Err("An error occurred when appending to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Returns `true` if the file `f` was created, and `false` if `f` was overwritten.
    ///
    pub def truncate(f: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import new java.io.PrintWriter(##java.io.File): ##java.io.PrintWriter & Impure as newPrintWriter;
            import java.io.PrintWriter.close(): Unit & Impure;
            import java.io.PrintWriter.checkError(): Bool & Impure;

            let alreadyExists = File.exists(f);

            let javaFile = newFile(f);
            let printWriter = newPrintWriter(javaFile);

            close(printWriter);

            if (checkError(printWriter)) {
                Err("An error occurred when truncating to the file: '${f}'.")
            }
            else {
                Result.flatMap(exists -> Ok(not exists), alreadyExists)
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

    ///
    /// Creates the directory `d`.
    ///
    /// Returns `Ok(true)` if the directory `d` was created and did not already exist.
    /// Returns `Ok(false)` if the directory `d` already existed and is a directory.
    /// Returns `Err(msg)` if the directory could not be created.
    ///
    pub def mkdir(d: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.mkdir(): Bool & Impure;

            let javaFile = newFile(d);
            Ok(mkdir(javaFile))
        } catch {
            case ex: ##java.io.IOException =>
            import java.lang.Throwable.getMessage(): String & Impure;
            Err(getMessage(ex))
        }

    ///
    /// Creates the directory `d` along with all necessary parent directories.
    ///
    /// Returns `Ok(true)` if the directory `d` was created and did not already exist.
    /// Returns `Ok(false)` if the directory `d` already existed and is a directory.
    /// Returns `Err(msg)` if the directory could not be created.
    ///
    pub def mkdirs(d: String): Result[Bool, String] & Impure =
        try {
            import new java.io.File(String): ##java.io.File & Impure as newFile;
            import java.io.File.mkdirs(): Bool & Impure;

            let javaFile = newFile(d);
            Ok(mkdirs(javaFile))
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & Impure;
                Err(getMessage(ex))
        }

}
