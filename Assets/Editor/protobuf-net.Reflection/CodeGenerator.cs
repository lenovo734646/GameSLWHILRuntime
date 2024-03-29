﻿using Google.Protobuf.Reflection;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;

namespace ProtoBuf.Reflection
{
    /// <summary>
    /// Abstract root for a general purpose code-generator
    /// </summary>
    public abstract class CodeGenerator
    {
        /// <summary>
        /// The logical name of this code generator
        /// </summary>
        public abstract string Name { get; }
        /// <summary>
        /// Get a string representation of the instance
        /// </summary>
        public override string ToString() => Name;



        /// <summary>
        /// Execute the code generator against a FileDescriptorSet, yielding a sequence of files
        /// </summary>
        public IEnumerable<CodeFile> Generate(FileDescriptorSet set, NameNormalizer normalizer) => Generate(set, normalizer, null);

        /// <summary>
        /// Execute the code generator against a FileDescriptorSet, yielding a sequence of files
        /// </summary>
        public abstract IEnumerable<CodeFile> Generate(FileDescriptorSet set, NameNormalizer normalizer = null, Dictionary<string,string> options = null);

        /// <summary>
        /// Eexecute this code generator against a code file
        /// </summary>
        public CompilerResult Compile(CodeFile file) => Compile(new[] { file });
        /// <summary>
        /// Eexecute this code generator against a set of code file
        /// </summary>
        public CompilerResult Compile(params CodeFile[] files)
        {
            var set = new FileDescriptorSet();
            foreach (var file in files)
            {
                using (var reader = new StringReader(file.Text))
                {
                    Console.WriteLine($"Parsing {file.Name}...");
                    set.Add(file.Name, true, reader);
                }
            }
            set.Process();
            var results = new List<CodeFile>();
            var newErrors = new List<Error>();

            try
            {
                results.AddRange(Generate(set));
            }
            catch (Exception ex)
            {
                set.Errors.Add(new Error(default(Token), ex.Message, true));
            }
            var errors = set.GetErrors();

            return new CompilerResult(errors, results.ToArray());
        }
    }
    /// <summary>
    /// Abstract base class for a code generator that uses a visitor pattern
    /// </summary>
    public abstract partial class CommonCodeGenerator : CodeGenerator
    {
        private Access? GetAccess(IType parent)
        {
            if (parent is DescriptorProto)
                return GetAccess((DescriptorProto)parent);
            if (parent is EnumDescriptorProto)
                return GetAccess((EnumDescriptorProto)parent);
            if (parent is FileDescriptorProto)
                return GetAccess((FileDescriptorProto)parent);
            return null;
        }
        /// <summary>
        /// Obtain the access of an item, accounting for the model's hierarchy
        /// </summary>
        protected Access GetAccess(FileDescriptorProto obj)
            => NullIfInherit(obj?.Options?.GetOptions()?.Access) ?? Access.Public;

        /// <summary>
        /// Get the language version for this language from a schema
        /// </summary>
        protected virtual string GetLanguageVersion(FileDescriptorProto obj) => null;
            

        static Access? NullIfInherit(Access? access)
            => access == Access.Inherit ? null : access;
        /// <summary>
        /// Obtain the access of an item, accounting for the model's hierarchy
        /// </summary>
        protected Access GetAccess(DescriptorProto obj)
            => NullIfInherit(obj?.Options?.GetOptions()?.Access)
            ?? NullIfInherit(GetAccess(obj?.Parent)) ?? Access.Public;
        /// <summary>
        /// Obtain the access of an item, accounting for the model's hierarchy
        /// </summary>
        protected Access GetAccess(FieldDescriptorProto obj)
            => NullIfInherit(obj?.Options?.GetOptions()?.Access)
            ?? NullIfInherit(GetAccess(obj?.Parent as IType)) ?? Access.Public;
        /// <summary>
        /// Obtain the access of an item, accounting for the model's hierarchy
        /// </summary>
        protected Access GetAccess(EnumDescriptorProto obj)
            => NullIfInherit(obj?.Options?.GetOptions()?.Access)
                ?? NullIfInherit(GetAccess(obj?.Parent)) ?? Access.Public;
        /// <summary>
        /// Get the textual name of a given access level
        /// </summary>
        public virtual string GetAccess(Access access)
            => access.ToString();
        
        /// <summary>
        /// The indentation used by this code generator
        /// </summary>
        public virtual string Indent => "    ";
        /// <summary>
        /// The file extension of the files generatred by this generator
        /// </summary>
        protected abstract string DefaultFileExtension { get; }

        /// <summary>
        /// Should case-sensitivity be used when computing conflicts?
        /// </summary>
        protected internal virtual bool IsCaseSensitive => false;

        /// <summary>
        /// Handle keyword escaping in the language of this code generator
        /// </summary>
        /// <param name="identifier"></param>
        /// <returns></returns>
        protected abstract string Escape(string identifier);
        /// <summary>
        /// Execute the code generator against a FileDescriptorSet, yielding a sequence of files
        /// </summary>
        public override IEnumerable<CodeFile> Generate(FileDescriptorSet set, NameNormalizer normalizer = null, Dictionary<string,string> options = null)
        {
            foreach (var file in set.Files)
            {
                if (!file.IncludeInOutput) continue;

                var fileName = Path.ChangeExtension(file.Name, DefaultFileExtension);

                string generated;
                using (var buffer = new StringWriter())
                {
                    var ctx = new GeneratorContext(this, file, normalizer, buffer, Indent, options);

                    ctx.BuildTypeIndex(); // populates for TryFind<T>
                    WriteFile(ctx, file);
                    generated = buffer.ToString();
                }
                yield return new CodeFile(fileName, generated);

            }

        }
        /// <summary>
        /// Emits the code for a file in a descriptor-set
        /// </summary>
        protected virtual void WriteFile(GeneratorContext ctx, FileDescriptorProto obj)
        {
            var file = ctx.File;
            object state = null;
            WriteFileHeader(ctx, obj, ref state);

            foreach (var inner in file.MessageTypes)
            {
                WriteMessage(ctx, inner);
            }
            foreach (var inner in file.EnumTypes)
            {
                WriteEnum(ctx, inner);
            }
            foreach (var inner in file.Services)
            {
                WriteService(ctx, inner);
            }
            if(file.Extensions.Count != 0)
            {
                object extState = null;
                WriteExtensionsHeader(ctx, file, ref extState);
                foreach(var ext in file.Extensions)
                {
                    WriteExtension(ctx, ext);
                }
                WriteExtensionsFooter(ctx, file, ref extState);
            }
            WriteFileFooter(ctx, obj, ref state);
        }
        /// <summary>
        /// Emit code representing an extension field
        /// </summary>
        protected virtual void WriteExtension(GeneratorContext ctx, FieldDescriptorProto ext) { }
        /// <summary>
        /// Emit code preceeding a set of extension fields
        /// </summary>
        protected virtual void WriteExtensionsHeader(GeneratorContext ctx, FileDescriptorProto file, ref object state) { }
        /// <summary>
        /// Emit code following a set of extension fields
        /// </summary>
        protected virtual void WriteExtensionsFooter(GeneratorContext ctx, FileDescriptorProto file, ref object state) { }
        /// <summary>
        /// Emit code preceeding a set of extension fields
        /// </summary>
        protected virtual void WriteExtensionsHeader(GeneratorContext ctx, DescriptorProto file, ref object state) { }
        /// <summary>
        /// Emit code following a set of extension fields
        /// </summary>
        protected virtual void WriteExtensionsFooter(GeneratorContext ctx, DescriptorProto file, ref object state) { }
        /// <summary>
        /// Emit code representing a service
        /// </summary>
        protected virtual void WriteService(GeneratorContext ctx, ServiceDescriptorProto obj)
        {
            object state = null;
            WriteServiceHeader(ctx, obj, ref state);
            foreach (var inner in obj.Methods)
            {
                WriteServiceMethod(ctx, inner, ref state);
            }
            WriteServiceFooter(ctx, obj, ref state);
        }
        /// <summary>
        /// Emit code following a set of service methods
        /// </summary>
        protected virtual void WriteServiceFooter(GeneratorContext ctx, ServiceDescriptorProto obj, ref object state) { }

        /// <summary>
        /// Emit code representing a service method
        /// </summary>
        protected virtual void WriteServiceMethod(GeneratorContext ctx, MethodDescriptorProto inner, ref object state) { }
        /// <summary>
        /// Emit code following preceeding a set of service methods
        /// </summary>
        protected virtual void WriteServiceHeader(GeneratorContext ctx, ServiceDescriptorProto obj, ref object state) { }
        /// <summary>
        /// Check whether a particular message should be suppressed - for example because it represents a map
        /// </summary>
        protected virtual bool ShouldOmitMessage(GeneratorContext ctx, DescriptorProto obj, ref object state)
            => obj.Options?.MapEntry ?? false; // don't write this type - use a dictionary instead

        /// <summary>
        /// Emit code representing a message type
        /// </summary>
        protected virtual void WriteMessage(GeneratorContext ctx, DescriptorProto obj)
        {
            object state = null;
            if (ShouldOmitMessage(ctx, obj, ref state)) return;

            WriteMessageHeader(ctx, obj, ref state);
            var oneOfs = OneOfStub.Build(ctx, obj);


            if(WriteContructorHeader(ctx, obj, ref state))
            {
                foreach(var inner in obj.Fields)
                {
                    WriteInitField(ctx, inner, ref state, oneOfs);
                }
                WriteConstructorFooter(ctx, obj, ref state);
            }
            foreach (var inner in obj.Fields)
            {
                WriteField(ctx, inner, ref state, oneOfs);
            }
            //Add by LiYu 2019.02.23 Begin
            WriteEncodeBegin(ctx, obj, ref state, oneOfs);
            foreach (var inner in obj.Fields)
            {
                WriteEncodeBody(ctx, inner, ref state, oneOfs);
            }
            WriteEncodeEnd(ctx, obj, ref state, oneOfs);
            WriteDecodeBegin(ctx, obj, ref state, oneOfs);
            foreach (var inner in obj.Fields)
            {
                WriteDecodeDefault(ctx, inner, ref state, oneOfs);
            }
            WriteDecodeTag(ctx, obj, ref state, oneOfs);
            foreach (var inner in obj.Fields)
            {
                WriteDecodeBody(ctx, inner, ref state, oneOfs);
            }
            WriteDecodeEnd(ctx, obj, ref state, oneOfs);
            //Add by LiYu 2019.02.23 End
            foreach (var inner in obj.NestedTypes)
            {
                WriteMessage(ctx, inner);
            }
            foreach (var inner in obj.EnumTypes)
            {
                WriteEnum(ctx, inner);
            }
            if (obj.Extensions.Count != 0)
            {
                object extState = null;
                WriteExtensionsHeader(ctx, obj, ref extState);
                foreach (var ext in obj.Extensions)
                {
                    WriteExtension(ctx, ext);
                }
                WriteExtensionsFooter(ctx, obj, ref extState);
            }
            WriteMessageFooter(ctx, obj, ref state);
        }

        /// <summary>
        /// Emit code terminating a constructor, if one is required
        /// </summary>
        protected virtual void WriteConstructorFooter(GeneratorContext ctx, DescriptorProto obj, ref object state) { }

        /// <summary>
        /// Emit code initializing field values inside a constructor, if one is required
        /// </summary>
        protected virtual void WriteInitField(GeneratorContext ctx, FieldDescriptorProto inner, ref object state, OneOfStub[] oneOfs) { }

        /// <summary>
        /// Emit code beginning a constructor, if one is required
        /// </summary>
        /// <returns>true if a constructor is required</returns>
        protected virtual bool WriteContructorHeader(GeneratorContext ctx, DescriptorProto obj, ref object state) => false;


        /// <summary>
        /// Emit code representing a message field
        /// </summary>
        protected abstract void WriteField(GeneratorContext ctx, FieldDescriptorProto obj, ref object state, OneOfStub[] oneOfs);

        protected abstract void WriteEncodeBegin(GeneratorContext ctx, DescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteEncodeBody(GeneratorContext ctx, FieldDescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteEncodeEnd(GeneratorContext ctx, DescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteDecodeBegin(GeneratorContext ctx, DescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteDecodeDefault(GeneratorContext ctx, FieldDescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteDecodeTag(GeneratorContext ctx, DescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteDecodeBody(GeneratorContext ctx, FieldDescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        protected abstract void WriteDecodeEnd(GeneratorContext ctx, DescriptorProto obj, ref object state, OneOfStub[] oneOfs);
        /// <summary>
        /// Emit code following a set of message fields
        /// </summary>
        protected abstract void WriteMessageFooter(GeneratorContext ctx, DescriptorProto obj, ref object state);
        /// <summary>
        /// Emit code preceeding a set of message fields
        /// </summary>
        protected abstract void WriteMessageHeader(GeneratorContext ctx, DescriptorProto obj, ref object state);
        /// <summary>
        /// Emit code representing an enum type
        /// </summary>
        protected virtual void WriteEnum(GeneratorContext ctx, EnumDescriptorProto obj)
        {
            object state = null;
            WriteEnumHeader(ctx, obj, ref state);
            foreach (var inner in obj.Values)
            {
                WriteEnumValue(ctx, inner, ref state);
            }
            WriteEnumFooter(ctx, obj, ref state);
        }

        /// <summary>
        /// Emit code preceeding a set of enum values
        /// </summary>
        protected abstract void WriteEnumHeader(GeneratorContext ctx, EnumDescriptorProto obj, ref object state);
        /// <summary>
        /// Emit code representing an enum value
        /// </summary>
        protected abstract void WriteEnumValue(GeneratorContext ctx, EnumValueDescriptorProto obj, ref object state);
        /// <summary>
        /// Emit code following a set of enum values
        /// </summary>
        protected abstract void WriteEnumFooter(GeneratorContext ctx, EnumDescriptorProto obj, ref object state);
        /// <summary>
        /// Emit code at the start of a file
        /// </summary>
        protected virtual void WriteFileHeader(GeneratorContext ctx, FileDescriptorProto obj, ref object state) { }
        /// <summary>
        /// Emit code at the end of a file
        /// </summary>
        protected virtual void WriteFileFooter(GeneratorContext ctx, FileDescriptorProto obj, ref object state) { }

        /// <summary>
        /// Represents the state of a code-generation invocation
        /// </summary>
        protected class GeneratorContext
        {
            /// <summary>
            /// The file being processed
            /// </summary>
            public FileDescriptorProto File { get; }
            /// <summary>
            /// The token to use for indentation
            /// </summary>
            public string IndentToken { get; }
            /// <summary>
            /// The current indent level
            /// </summary>
            public int IndentLevel { get; private set; }
            /// <summary>
            /// The mechanism to use for name normalization
            /// </summary>
            public NameNormalizer NameNormalizer { get; }
            /// <summary>
            /// The output for this code generation
            /// </summary>
            public TextWriter Output { get; }
            /// <summary>
            /// The effective syntax of this code-generation cycle, defaulting to "proto2" if not explicity specified
            /// </summary>
            public string Syntax => string.IsNullOrWhiteSpace(File.Syntax) ? FileDescriptorProto.SyntaxProto2 : File.Syntax;
            /// <summary>
            /// Create a new GeneratorContext instance
            /// </summary>
            internal GeneratorContext(CommonCodeGenerator generator, FileDescriptorProto file, NameNormalizer nameNormalizer, TextWriter output, string indentToken, Dictionary<string,string> options)
            {
                if(nameNormalizer == null)
                {
                    string nn = null;
                    if (options != null) options.TryGetValue("names", out nn);
                    // todo: support getting from a .proto extension?

                    if (nn != null) nn = nn.Trim();
                    if (string.Equals(nn, "auto", StringComparison.OrdinalIgnoreCase)) nameNormalizer = NameNormalizer.Default;
                    else if (string.Equals(nn, "original", StringComparison.OrdinalIgnoreCase)) nameNormalizer = NameNormalizer.Null;
                }
                
                string langver = null;
                if (options != null) options.TryGetValue("langver", out langver); // explicit option first
                if (string.IsNullOrWhiteSpace(langver)) langver = generator?.GetLanguageVersion(file); // then from file

                if(nameNormalizer == null)
                {
                    nameNormalizer = NameNormalizer.Default;
                }
                nameNormalizer.IsCaseSensitive = generator.IsCaseSensitive;

                File = file;
                NameNormalizer = nameNormalizer;
                Output = output;
                IndentToken = indentToken;

                LanguageVersion = ParseVersion(langver);
                EmitRequiredDefaults = file.Options.GetOptions()?.EmitRequiredDefaults ?? false;
                _options = options;
            }

            private Dictionary<string, string> _options;
            /// <summary>
            /// Gets the value of an OPTION/VALUE pair provided to the system
            /// </summary>
            public string GetCustomOption(string key)
            {
                string value = null;
                _options?.TryGetValue(key, out value);
                return value;
            }

            static Version ParseVersion(string version)
            {
                if (string.IsNullOrWhiteSpace(version)) return null;
                version = version.Trim();
                Version v;
                if (Version.TryParse(version, out v)) return v;
                int i;
                if (int.TryParse(version, NumberStyles.Integer, CultureInfo.InvariantCulture, out i))
                    return new Version(i, 0);

                return null;
            }

            /// <summary>
            /// Should default value initializers be emitted even for required values?
            /// </summary>
            internal bool EmitRequiredDefaults { get; set; }

            internal bool Supports(Version version)
            {
                if (version == null) return true;
                var langver = LanguageVersion;
                if (langver == null) return true; // default is highest
                return langver >= version;
            }

            /// <summary>
            /// The specified language version (null if not specified)
            /// </summary>
            public Version LanguageVersion { get; }

            /// <summary>
            /// Ends the current line
            /// </summary>
            public GeneratorContext WriteLine()
            {
                Output.WriteLine();
                return this;
            }
            /// <summary>
            /// Appends a value and ends the current line
            /// </summary>
            public GeneratorContext WriteLine(string line)
            {
                var indentLevel = IndentLevel;
                var target = Output;
                while (indentLevel-- > 0)
                {
                    target.Write(IndentToken);
                }
                target.WriteLine(line);
                return this;
            }
            /// <summary>
            /// Appends a value to the current line
            /// </summary>
            public TextWriter Write(string value)
            {
                var indentLevel = IndentLevel;
                var target = Output;
                while (indentLevel-- > 0)
                {
                    target.Write(IndentToken);
                }
                target.Write(value);
                return target;
            }
            /// <summary>
            /// Increases the indentation level
            /// </summary>
            public GeneratorContext Indent()
            {
                IndentLevel++;
                return this;
            }
            /// <summary>
            /// Decreases the indentation level
            /// </summary>
            public GeneratorContext Outdent()
            {
                IndentLevel--;
                return this;
            }

            /// <summary>
            /// Try to find a descriptor of the type specified by T with the given full name
            /// </summary>
            public T TryFind<T>(string typeName) where T : class
            {
                object obj;
                if (!_knownTypes.TryGetValue(typeName, out obj) || obj == null)
                {
                    return null;
                }
                return obj as T;
            }

            private Dictionary<string, object> _knownTypes = new Dictionary<string, object>();
			void AddMessage(DescriptorProto message)
			{
				_knownTypes[message.FullyQualifiedName] = message;
				foreach (var @enum in message.EnumTypes)
				{
					_knownTypes[@enum.FullyQualifiedName] = @enum;
				}
				foreach (var msg in message.NestedTypes)
				{
					AddMessage(msg);
				}
			}
            internal void BuildTypeIndex()
            {
                {
                    var processedFiles = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    var pendingFiles = new Queue<FileDescriptorProto>();

                    _knownTypes.Clear();
                    processedFiles.Add(File.Name);
                    pendingFiles.Enqueue(File);

                    while (pendingFiles.Count != 0)
                    {
                        var file = pendingFiles.Dequeue();

                        foreach (var @enum in file.EnumTypes)
                        {
                            _knownTypes[@enum.FullyQualifiedName] = @enum;
                        }
                        foreach (var msg in file.MessageTypes)
                        {
                            AddMessage(msg);
                        }

                        if (file.HasImports())
                        {
                            foreach (var import in file.GetImports())
                            {
                                if (processedFiles.Add(import.Path))
                                {
                                    var importFile = file.Parent.GetFile(file, import.Path);
                                    if (importFile != null) pendingFiles.Enqueue(importFile);
                                }
                            }
                        }

                    }
                }
            }
        }
    }


}
