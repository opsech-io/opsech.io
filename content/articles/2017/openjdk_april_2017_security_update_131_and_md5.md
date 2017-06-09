Title: OpenJDK April 2017 security update 131 (8u131) and MD5 signed jars
Category: fixes
Tags: java, openjdk, ipmi
Date: Fri Jun  9 09:59:07 EDT 2017
Status: published

    ::text
    10:00:58 up 101 days, 14:17,  1 user,  load average: 1.47, 1.07, 0.99

It's been a few months since I last rebooted my home NAS, and I wanted to do something in the UEFI that required a full reboot and virtual console. The usual procedure for this is to login to the BMC's website and download a `jviewer.jnlp` that is in turn run by `javaws.itweb` (on Fedora/RHEL, `javaws` to everyone else), then off I go doing admin things...

Unbeknownst to me, the latest [April patches that correspond to
Java™ SE Development Kit 8, Update 131 (JDK 8u131)](http://www.oracle.com/technetwork/java/javase/8u131-relnotes-3565278.html) disabled the MD5 algorithm for jar signatures.

The changelog above reads as follows:

>`security-libs/java.security`
>
>**MD5 added to jdk.jar.disabledAlgorithms Security property**
>
>This JDK release introduces a new restriction on how MD5 signed JAR files are verified. If the signed JAR file uses MD5, signature verification operations will ignore the signature and treat the JAR as if it were unsigned. This can potentially occur in the following types of applications that use signed JAR files:
>
>*   Applets or Web Start Applications
>*   Standalone or Server Applications that are run with a SecurityManager enabled and are configured with a policy file that grants permissions based on the code signer(s) of the JAR file.
>
>
>The list of disabled algorithms is controlled via the security property, `jdk.jar.disabledAlgorithms`, in the `java.security` file. This property contains a list of disabled algorithms and key sizes for cryptographically signed JAR files.





The initial error message was not self-evident at first. As OpenJDK, at least on Fedora 25 where I am currently using it, only exposed the following error:

    ::text
    netx: Initialization Error: Could not initialize application. (Fatal: Application Error: Cannot grant permissions to unsigned jars. Application requested security permissions, but jars are not signed.)

That's all fine and dandy, but what am I supposed to do about a BMC that is out of support? Obviously it's unrealistic to expect an out of support board to get a firmware update to ever really address this issue.

The error never hints toward the fact that it _was_ in fact signed, but said signature was being ignored as _unsigned_ due to the new security settings above. (Note: I think it's a terrible idea to abstract something like this as "unsigned", when it should tell you exactly what is wrong.)

I went on tweaking security settings and profiles for the next few hours bewildered at why this was working the last time I needed to use it, but suddenly not now. Usually with these things the right security settings, or adding an exception with a little rain dance and vile of sysadmin tears gets it working again, but not this time (It didn't yet occur to me to check the java changelog.) So the next thing I did was test it with Oracle's Java SE, and that's when I found the _actual_ error:

    ::text
    Error: Unsigned application requesting unrestricted access to system
           The following resource is signed with a weak algorithm MD5withRSA and is treated as unsigned:


(likely because I was testing now in a windows VM to see if I could get it to work and the jar for this is a separate win32.jar)

This gave me my first real clue, as searching the web for "Cannot grant permissions to unsigned jars." yields a lot of angry people complaining about IPMI/KVM viewers not working (SuperMicro, ASRock Rack, Dell iDRAC, etc), but not a single solution other than "Use an older version of java" - no one in this search set seemed to figure out the `jdk.jar.disabledAlgorithms` property, nor either that the specific breaking change was in `8u131`.

Moving on, a searching of the new error message finally yielded [this blog](https://wuzhaojun.wordpress.com/2017/05/05/a-workaround-to-fix-unsigned-jnlp-issue-after-upgrade-java-to-version-8-update-131/) and led me to the answer of how to get my KVM viewer working again.

### Solution

In order to get this working agian, the file `/usr/lib/jvm/java-<version>-openjdk-<version>.<nevra>/jre/lib/security/java.security` ("java.security") must be edited to completely comment out or tailor the `jdk.jar.disabledAlgorithms` setting to your needs.

You can acquire more information about your `jnlp` by finding the `icedtea-web` cache and running `jarsigner -verify --verbose file.jar` (in my case it was under `~/.cache/icedtea-web/cache`). This shows the following info:

    ::text
    - Signed by "CN=ASROCK Incorporation, OU=Digital ID Class 3 - Microsoft Software Validation v2, O=ASROCK Incorporation, L=Taipei, ST=TAIWAN, C=TW"
        Digest algorithm: SHA1
        Signature algorithm: MD5withRSA (weak), 2048-bit key

    WARNING: The jar will be treated as unsigned, because it is signed with a weak algorithm that is now disabled by the security property:

      jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024

Now you know you need to remove `MD5` from the list of banned algorithms:

    ::diff
    --- /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.fc25.x86_64/jre/lib/security/java.security.orig  2017-06-09 09:17:33.179272834 -0400
    +++ /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.fc25.x86_64/jre/lib/security/java.security  2017-06-09 09:48:22.086346183 -0400
    @@ -557,7 +557,7 @@
     # implementation. It is not guaranteed to be examined and used by other
     # implementations.
     #
    -jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024
    +jdk.jar.disabledAlgorithms=MD2, RSA keySize < 1024

     # Algorithm restrictions for Secure Socket Layer/Transport Layer Security
     # (SSL/TLS) processing

Yes, as suggested by the changelog entry this is less than ideal, but I've accepted it as a calculated risk, given that I _only_ use java for this one specific application.
