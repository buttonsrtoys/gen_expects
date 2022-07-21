# gen_key

`gen_key` is a code generator for Flutter widget keys files. 

Widget keys must be of the form `KeyClassName.keyName`:

    Text('Hello', key: MyWidgetKeys.helloText);

To generate widget keys, first reference the key in your widget:

    class MyWidget {
      @override
      Widget build(BuildContext context) {
        return Text('Hello', key: MyWidgetKeys.helloText);    // <- Your key reference
      }
    }

Then annotate the class with `@GenKey()`:

    @GenKey()      // <- Add annotation
    class MyWidget {
      @override
      Widget build(BuildContext context) {
        return Text('Hello', key: MyWidgetKeys.helloText);
      }
    }

`gen_key` parses the code and generates a separate key class that contains the keys.

    class MyWidgetKeys {
      static const String _prefix = '__MyWidgetKeys__';
      static const Key helloText = Key('${_prefix}helloText');
    }

The key class is a separate file that ends in `.keys.dart` that accompanies your class's `.dart` file. So, the keys in `my_widget.dart` are generated to `my_widget.keys.dart`. This is done by placing the `part` command at the top of your Dart file:

    part `my_widget.keys.dart`     // Add 'part'

    @GenKey()
    class MyWidget {
      @override
      Widget build(BuildContext context) {
        return Text('Hello', key: MyWidgetKeys.helloText);
      }
    }

Sometimes a class references references keys your don't want. In that cases, give all the class names you want to the `GenKey` command:

    @GenKey((keyClasses: ['MyWidgetKeys'])     // <- Specify which keys to generate here
    class MyWidget {
      @override
      Widget build(BuildContext context) {
        return Row(children: <Widget> [
          Text('Hello', key: MyWidgetKeys.helloText),    // <- You want key generation for this key
          Text('There', key: SomeoneElsesWidgetKeys.buttonText),     // <- But not for this one
        ]);
      }
    }

To generate the key files, run `flutter pub run build runner build`.

## Example

For a more detailed example, check out [the example]() in the package for large example.



