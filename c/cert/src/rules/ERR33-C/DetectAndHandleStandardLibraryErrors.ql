/**
 * @id c/cert/detect-and-handle-standard-library-errors
 * @name ERR33-C: Detect and handle standard library errors
 * @description Detect and handle standard library errors.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.commons.NULL
import codingstandards.cpp.ReadErrorsAndEOF
import semmle.code.cpp.dataflow.DataFlow

/**
 * Classifies error returning function calls based on the
 * type and value of the required checked
 */
class ExpectedErrReturn extends FunctionCall {
  Expr errValue;
  string errOperator;

  ExpectedErrReturn() {
    errOperator = ["==", "!="] and
    (
      errValue.(Literal).getValue() = "0" and
      this.getTarget()
          .hasName([
              "asctime_s", "at_quick_exit", "atexit", "ctime_s", "fgetpos", "fopen_s", "freopen_s",
              "fseek", "fsetpos", "mbsrtowcs_s", "mbstowcs_s", "raise", "remove", "rename",
              "setvbuf", "strerror_s", "strftime", "strtod", "strtof", "strtold", "timespec_get",
              "tmpfile_s", "tmpnam_s", "tss_get", "wcsftime", "wcsrtombs_s", "wcstod", "wcstof",
              "wcstold", "wcstombs_s", "wctrans", "wctype"
            ])
      or
      errValue instanceof NULL and
      this.getTarget()
          .hasName([
              "aligned_alloc", "bsearch_s", "bsearch", "calloc", "fgets", "fopen", "freopen",
              "getenv_s", "getenv", "gets_s", "gmtime_s", "gmtime", "localtime_s", "localtime",
              "malloc", "memchr", "realloc", "setlocale", "strchr", "strpbrk", "strrchr", "strstr",
              "strtok_s", "strtok", "tmpfile", "tmpnam", "wcschr", "wcspbrk", "wcsrchr", "wcsstr",
              "wcstok_s", "wcstok", "wmemchr"
            ])
      or
      errValue = any(EOFInvocation i).getExpr() and
      this.getTarget()
          .hasName([
              "fclose", "fflush", "fputs", "fputws", "fscanf_s", "fscanf", "fwscanf_s", "fwscanf",
              "scanf_s", "scanf", "sscanf_s", "sscanf", "swscanf_s", "swscanf", "ungetc",
              "vfscanf_s", "vfscanf", "vfwscanf_s", "vfwscanf", "vscanf_s", "vscanf", "vsscanf_s",
              "vsscanf", "vswscanf_s", "vswscanf", "vwscanf_s", "vwscanf", "wctob", "wscanf_s",
              "wscanf", "fgetc", "fputc", "getc", "getchar", "putc", "putchar", "puts"
            ])
      or
      errValue = any(WEOFInvocation i).getExpr() and
      this.getTarget()
          .hasName([
              "btowc", "fgetwc", "fputwc", "getwc", "getwchar", "putwc", "ungetwc", "putwchar"
            ])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_error") and
      this.getTarget()
          .hasName([
              "cnd_broadcast", "cnd_init", "cnd_signal", "cnd_timedwait", "cnd_wait", "mtx_init",
              "mtx_lock", "mtx_timedlock", "mtx_trylock", "mtx_unlock", "thrd_create",
              "thrd_detach", "thrd_join", "tss_create", "tss_set"
            ])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_nomem") and
      this.getTarget().hasName(["cnd_init", "thrd_create"])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_timedout") and
      this.getTarget().hasName(["cnd_timedwait", "mtx_timedlock"])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_busy") and
      this.getTarget().hasName(["mtx_trylock"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "UINTMAX_MAX").getExpr() and
      this.getTarget().hasName(["strtoumax", "wcstoumax"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "ULONG_MAX").getExpr() and
      this.getTarget().hasName(["strtoul", "wcstoul"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "ULLONG_MAX").getExpr() and
      this.getTarget().hasName(["strtoull", "wcstoull"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "SIG_ERR").getExpr() and
      this.getTarget().hasName(["signal"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["INTMAX_MAX", "INTMAX_MIN"]).getExpr() and
      this.getTarget().hasName(["strtoimax", "wcstoimax"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["LONG_MAX", "LONG_MIN"]).getExpr() and
      this.getTarget().hasName(["strtol", "wcstol"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["LLONG_MAX", "LLONG_MIN"]).getExpr() and
      this.getTarget().hasName(["strtoll", "wcstoll"])
      or
      errValue.(UnaryMinusExpr).getOperand().(Literal).getValue() = "1" and
      this.getTarget()
          .hasName([
              "c16rtomb", "c32rtomb", "clock", "ftell", "mbrtoc16", "mbrtoc32", "mbsrtowcs",
              "mbstowcs", "mktime", "time", "wcrtomb", "wcsrtombs", "wcstombs"
            ])
      or
      errValue.(UnaryMinusExpr).getOperand().(Literal).getValue() = "1" and
      not this.getArgument(0) instanceof NULL and
      this.getTarget().hasName(["mblen", "mbrlen", "mbrtowc", "mbtowc", "wctomb_s", "wctomb"])
      or
      errValue.getType() instanceof IntType and
      this.getTarget().hasName(["fread", "fwrite"])
    )
    or
    errOperator = ["<", ">="] and
    (
      errValue.(Literal).getValue() = "0" and
      this.getTarget()
          .hasName([
              "fprintf_s", "fprintf", "fwprintf_s", "fwprintf", "printf_s", "snprintf_s",
              "snprintf", "sprintf_s", "sprintf", "swprintf_s", "swprintf", "thrd_sleep",
              "vfprintf_s", "vfprintf", "vfwprintf_s", "vfwprintf", "vprintf_s", "vsnprintf_s",
              "vsnprintf", "vsprintf_s", "vsprintf", "vswprintf_s", "vswprintf", "vwprintf_s",
              "wprintf_s", "printf", "vprintf", "wprintf", "vwprintf"
            ])
      or
      errValue.getType() instanceof IntType and
      this.getTarget().hasName(["strxfrm", "wcsxfrm"])
    )
    or
    errOperator = "NA" and
    (
      errValue = any(Expr e) and
      this.getTarget()
          .hasName([
              "kill_dependency", "memcpy", "wmemcpy", "memmove", "wmemmove", "strcpy", "wcscpy",
              "strncpy", "wcsncpy", "strcat", "wcscat", "strncat", "wcsncat", "memset", "wmemset"
            ])
    )
  }

  Expr getErrValue() { result = errValue }

  string getErrOperator() { result = errOperator }
}

// Nodes following a file write before a call to `ferror` is performed
ControlFlowNode ferrorNotchecked(FileWriteFunctionCall write) {
  result = write
  or
  exists(ControlFlowNode mid |
    mid = ferrorNotchecked(write) and
    //do not traverse the short-circuited CFG edge
    not isShortCircuitedEdge(mid, result) and
    result = mid.getASuccessor() and
    //Stop recursion on call to ferror on the correct file
    not accessSameTarget(result.(FerrorCall).getArgument(0), write.getFileExpr())
  )
}

from ExpectedErrReturn err
where
  not isExcluded(err, Contracts5Package::detectAndHandleStandardLibraryErrorsQuery()) and
  // calls that must be verified using the return value
  not exists(ComparisonOperation op |
    DataFlow::localExprFlow(err, op.getAnOperand()) and
    (err.getErrOperator() != "NA" implies op.getOperator() = err.getErrOperator()) and
    op.getAnOperand() = err.getErrValue() and
    // special case for function `realloc` where the returned pointer
    // should not be invalidated
    not (
      err.getTarget().hasName("realloc") and
      op.getAnOperand().(VariableAccess).getTarget() =
        err.getArgument(0).(VariableAccess).getTarget()
    )
  ) and
  // EXCEPTIONS
  (
    // calls that can be verified using ferror() && feof()
    err.getTarget().hasName(["fgetc", "fgetwc", "getc", "getchar"])
    implies
    missingFeofFerrorChecks(err)
  ) and
  (
    // calls that can be verified using ferror()
    err.getTarget().hasName(["fputc", "putc"])
    implies
    err.getEnclosingFunction() = ferrorNotchecked(err)
  ) and
  (
    // ERR33-C-EX1: calls that can be ignored when cast to `void`
    err.getTarget()
        .hasName([
            "putchar", "putwchar", "puts", "printf", "vprintf", "wprintf", "vwprintf",
            "kill_dependency", "memcpy", "wmemcpy", "memmove", "wmemmove", "strcpy", "wcscpy",
            "strncpy", "wcsncpy", "strcat", "wcscat", "strncat", "wcsncat", "memset", "wmemset"
          ])
    implies
    not err.getExplicitlyConverted() instanceof VoidConversion
  )
select err,
  "Missing error detection for the call to function `" + err.getTarget() +
    "`. Undetected failures can lead to unexpected or undefined behavior."
